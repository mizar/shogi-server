#
# Autogenerated by Thrift
#
# DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING
#

require 'thrift'
require 'thrift/protocol'
require File.dirname(__FILE__) + '/graphicserver_types'

module ShogiGraphic
  class Client
    include Thrift::Client

    def usi2png(usi)
      send_usi2png(usi)
      return recv_usi2png()
    end

    def send_usi2png(usi)
      send_message('usi2png', Usi2png_args, :usi => usi)
    end

    def recv_usi2png()
      result = receive_message(Usi2png_result)
      return result.success unless result.success.nil?
      raise Thrift::ApplicationException.new(Thrift::ApplicationException::MISSING_RESULT, 'usi2png failed: unknown result')
    end

  end

  class Processor
    include Thrift::Processor

    def process_usi2png(seqid, iprot, oprot)
      args = read_args(iprot, Usi2png_args)
      result = Usi2png_result.new()
      result.success = @handler.usi2png(args.usi)
      write_result(result, oprot, 'usi2png', seqid)
    end

  end

  # HELPER FUNCTIONS AND STRUCTURES

  class Usi2png_args
    include Thrift::Struct
    USI = 1

    Thrift::Struct.field_accessor self, :usi
    FIELDS = {
      USI => {:type => Thrift::Types::STRING, :name => 'usi'}
    }
    def validate
    end

  end

  class Usi2png_result
    include Thrift::Struct
    SUCCESS = 0

    Thrift::Struct.field_accessor self, :success
    FIELDS = {
      SUCCESS => {:type => Thrift::Types::STRING, :name => 'success'}
    }
    def validate
    end

  end

end

