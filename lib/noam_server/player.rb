module NoamServer
  class Player

    attr_accessor :last_activity
    attr_reader :spalla_id, :device_type, :system_version, :hears, :plays, :host, :port, :room_name
    def device_key
      (@device_type || "").downcase
    end

    def initialize(spalla_id, device_type, system_version, hears, plays, host, port)
      @spalla_id = spalla_id
      @device_type = device_type
      @system_version = system_version
      @hears = hears || []
      @plays = plays || []
      @host = host
      @port = port
      @room_name = NoamServer.room_name
      NoamLogging.debug(self, "New Player:")
      NoamLogging.debug(self, "   Hears: #{@hears}")
      NoamLogging.debug(self, "   Plays: #{@plays}")
      NoamLogging.debug(self, "   Plays: #{@room_name}")
    end

    def in_right_room?()
      NoamLogging.info(self, "Player in room ?" + NoamServer.room_name + " - " + @room_name)
      @room_name == NoamServer.room_name
    end

    def hears?(event)
      @hears.include?(event)
    end

    def plays?(event)
      @plays.include?(event)
    end

    def learn_to_play(event)
      @plays << event unless @plays.include?(event)
    end
  end
end
