require 'noam/messages'

module NoamServer
  module EarHandler
    attr_accessor :parent
    def unbind
      parent.disconnect
    end
  end

  class Ear
    attr_accessor :host, :port

    def initialize(host, port)
      @conection_pending = false
      @host = host
      @port = port
      @terminated = false
      new_connection
    end

    def send_data(data)
      if @connection and active?
        @connection.send_data("%06d" % data.bytesize)
        @connection.send_data(data)
        return true
      else
        return false
      end
    end

    def new_connection
      unless @connection_pending
        @connection_pending = true
#        p "testing" + @host.to_s + " : " + @port.to_s
        EventMachine::connect(@host, @port, EarHandler) do |connection|
          @connection = connection
          @connection.parent = self
          yield(@connection) if block_given?
          @connection_pending = false
        end
      end
    end

    def active?
      (not @connection.nil? and not @terminated) or @connection_pending
    end

    def disconnect
      terminate
      @connection = nil
      @connection_pending = false
    end

    def terminate
      @terminated = true
      @connection.close_connection_after_writing if @connection
    end
  end
end
