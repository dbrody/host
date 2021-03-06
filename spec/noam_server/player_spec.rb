#Copyright (c) 2014, IDEO 

require 'noam_server/player'

describe NoamServer::Player do
  let(:spalla_id) { "Spalla ID" }
  let(:device_type) { "Device Type" }
  let(:system_version) { "System Version" }
  let(:hears) { %w(speed rpm cruise_target) }
  let(:plays) { %w(speed volume) }
  let(:host) { "192.168.0.12" }
  let(:port) { 8943 }
  let(:room_name) { "RoomName" }
  let(:player) { described_class.new( spalla_id, device_type, system_version, hears, plays, host, port, room_name )}

  it 'has spalla id' do
    player.spalla_id.should == spalla_id
  end

  it 'has device type' do
    player.device_type.should == device_type
  end

  it 'has system version' do
    player.system_version.should == system_version
  end

  it 'has host' do
    player.host.should == "192.168.0.12"
  end

  it 'has port' do
    player.port.should == 8943
  end

  it 'has last activity' do
    now = DateTime.now
    player.last_activity = now
    player.last_activity.should == now
  end

  it "hears" do
    hears.each do |event|
      player.hears?(event).should be_true
    end
  end

  it 'has room name' do
    player.room_name.should == room_name
  end

  it "does not hear" do
    player.hears?("volume").should be_false
  end

  it "does not play" do
    player.plays?("rpm").should be_false
  end

  it "plays" do
    plays.each do |event|
      player.plays?(event).should be_true
    end
  end

  it "adds notes to plays" do
    player.learn_to_play("window_state")
    player.plays?("window_state").should == true
  end

  it "does not duplicate notes" do
    player.learn_to_play("window_state")
    size = player.plays.size
    player.learn_to_play("window_state")
    player.plays.size.should == size
  end

end
