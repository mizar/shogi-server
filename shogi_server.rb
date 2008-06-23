## $Id$

## Copyright (C) 2004 NABEYA Kenichi (aka nanami@2ch)
## Copyright (C) 2007-2008 Daigo Moriwaki (daigo at debian dot org)
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

require 'kconv'
require 'getoptlong'
require 'thread'
require 'timeout'
require 'socket'
require 'yaml'
require 'yaml/store'
require 'digest/md5'
require 'webrick'
require 'fileutils'
require 'logger'

require 'rubygems'
require 'active_support'
Dependencies.log_activity = true
Dependencies.load_paths << File.dirname(__FILE__)
RAILS_DEFAULT_LOGGER = Logger.new($stdout) if $DEBUG

module ShogiServer # for a namespace

Max_Identifier_Length = 32
Default_Timeout = 60            # for single socket operation
Default_Game_Name = "default-1500-0"
One_Time = 10
Least_Time_Per_Move = 1
Login_Time = 300                # time for LOGIN
Release  = "$Id$"
Revision = (r = /Revision: (\d+)/.match("$Revision$") ? r[1] : 0)

class Formatter < ::Logger::Formatter
  def call(severity, time, progname, msg)
    %!%s [%s] %s\n! % [format_datetime(time), severity, msg2str(msg)]
  end
end

end # module ShogiServer