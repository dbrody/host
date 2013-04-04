require 'noam_server/orchestra'
require 'noam/messages'
require 'noam_server/ear'
require 'noam_server/player_connection'
require 'noam_server/attenuated_player_connection'
require 'noam_server/player'
module NoamServer

  class MessageHandler
    def initialize(ip)
      @ip = ip
    end

    def message_received(message)
      if message.is_a?(Noam::Messages::RegisterMessage)
        player = Player.new( message.spalla_id, message.device_type, message.system_version, message.hears, message.plays, @ip, message.callback_port)

        ear = Ear.new( player.host, player.port )
        player_connection = if message.device_type == "arduino"
          AttenuatedPlayerConnection.new( ear, 0.1)
        else
          PlayerConnection.new( ear )
        end

        orchestra.register(player_connection, player)
      elsif message.is_a?(Noam::Messages::EventMessage)
        orchestra.play(message.event_name, message.event_value, message.spalla_id)
      end
    end

    def orchestra
      Orchestra.instance
    end
  end
end