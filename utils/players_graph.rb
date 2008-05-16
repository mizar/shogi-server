#!/usr/bin/ruby
#    This generates graphs of evaluation values from comments in CSA files.
#    Ruby libraries that are required: 
#      - RubyGems: http://rubyforge.org/projects/rubygems/
#      - rgplot:   http://rubyforge.org/projects/rgplot/
#    OS librariles that is required:
#      - Gnuplot:  http://www.gnuplot.info/
#                  On Debian, $ sudo apt-get install gnuplot
#    
#    Copyright (C) 2008  Daigo Moriwaki <daigo@debian.org>
#
#    Version: $Id$
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA

require 'pathname'
require 'getoptlong'
require 'yaml'
require 'date'
require 'set'
require 'rubygems'
require 'gnuplot'

$players = {}

class Format
  attr_reader :ext, :size
  def initialize(root)
    @root = root
    @size = "1,1"
  end

  def apply(plot)
    plot.terminal @ext
    plot.size     @size
  end
end

class LargeFormat < Format
  def initialize(root)
    super
  end

  def apply(plot)
    super
    plot.format 'x "%y/%m/%d"'
    plot.ytics  "100"
    plot.mytics "5"
  end
end

class LargePngFormat < LargeFormat
  def initialize(root)
    super
    @ext = "png"
  end

  def to_image_file(name)
    return File.join(@root, "#{name}-large.#{ext}")
  end
end

class SmallPngFormat < Format
  def initialize(root)
    super
    @ext = "png"
    @size = "0.4,0.4"
  end

  def to_image_file(name)
    return File.join(@root, "#{name}-small.#{ext}")
  end

  def apply(plot)
    super
    plot.format 'x "%b"'
    plot.ytics  "200"
    plot.mytics "2"
  end
end

class SvgFormat < LargeFormat
  def initialize(root)
    super
    @ext = "svg"
  end

  def to_image_file(name)
    return File.join(@root, "#{name}.#{ext}")
  end
end

def plot(format, name, dates, rates, rdates, rrates)
  Gnuplot.open do |gp|
    Gnuplot::Plot.new( gp ) do |plot|
      format.apply(plot)
      plot.title   name
      plot.output format.to_image_file(name)
      
      plot.size    "ratio #{1/1.618}"
      plot.xlabel  "Date"
      plot.ylabel  "Rate"
      plot.xdata   "time"
      plot.timefmt '"%Y-%m-%d"'
      plot.xrange  "[\"%s\":\"%s\"]" % 
                    [dates.first.strftime("%Y-%m-%d"),
                     dates.last.strftime("%Y-%m-%d")]
      ymin = ((rates + rrates).min/50) * 50
      ymax = ((rates + rrates).max/50 + 1) * 50
      plot.yrange "[%s:%s]" % [ymin, ymax]
      plot.grid
      data = []
      data << Gnuplot::DataSet.new([dates, rates]) do |ds|
                ds.using = "1:2"
                ds.with  = "lines"
                ds.title = "original"
              end
      if !rdates.empty?
        data << Gnuplot::DataSet.new([rdates, rrates]) do |ds|
                  ds.using = "1:2"
                  ds.with  = "lines"
                  ds.title = "relative (rate24)"
                end
      end
      plot.data = data
    end
  end  
end

def load_file(file_name)
  if /^.*-(\d{8}).yaml$/ =~ file_name
    date = Date::parse($1)
  else
    return
  end
  db = YAML::load_file(file_name)
  return unless db['players'][0]
  db['players'][0].each do |name, hash|
    $players[name] ||= {}
    $players[name][date] = hash['rate'].to_i
  end
end

if $0 == __FILE__
  def usage
    puts "Usage: #{$0} [--output-dir dir] <players_yaml_files>..."
    puts "Options:"
    puts "  --output-dir dir  Images will be located in the dir."
    exit 1
  end

  usage if ARGV.empty?

  parser = GetoptLong.new
  parser.set_options(['--output-dir', '-o', GetoptLong::REQUIRED_ARGUMENT])
  begin
    parser.each_option do |name, arg|
      eval "$OPT_#{name.sub(/^--/, '').gsub(/-/, '_').upcase} = '#{arg}'"
    end
  rescue
    usage
  end
  
  while file = ARGV.shift
    load_file(file)
  end
  
  formats = [LargePngFormat.new($OPT_OUTPUT_DIR),
             SmallPngFormat.new($OPT_OUTPUT_DIR),
             SvgFormat.new($OPT_OUTPUT_DIR)]

  $players.each do |name, hash|
    dates, rates = hash.sort.transpose
    rdates = dates.find_all do |date| 
      $players["YSS+707d4f98d9d2620cdaab58f19d02a2e4"] &&
      $players["YSS+707d4f98d9d2620cdaab58f19d02a2e4"][date] 
    end
    rrates = rdates.map do |date|
      2300 - $players["YSS+707d4f98d9d2620cdaab58f19d02a2e4"][date] + hash[date]
    end
    formats.each do |format|
      plot(format, name, dates, rates, rdates, rrates)
    end
  end
end

