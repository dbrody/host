require 'progenitor/orchestra'
require 'progenitor/player'
require 'progenitor/player_connection'

describe Progenitor::Orchestra do
  let(:orchestra) { described_class.new }

  let(:id_1) { 'Arduino #1' }
  let(:id_2) { 'Raspberry Pi #2' }
  let(:player_1 ) { Progenitor::Player.new( id_1, 'Virtual Machine', 'System Version',
                                           ["listens_for_1", "listens_for_2"],
                                           ["plays_1", "plays_2"])}
  let(:player_2) { Progenitor::Player.new( id_2, 'Pi', 'System Version', [], []) }

  let(:connection_1) { Progenitor::PlayerConnection.new( player_1 )}
  let(:connection_2) { Progenitor::PlayerConnection.new( player_2 )}


  it "plays a note noone has registered for" do
    -> {orchestra.play( 'player', 'listens_for_1', 12.42 )}.should_not raise_error
  end

  it "implements a Singleton" do
    described_class.instance.should === described_class.instance
  end

  it "should register players" do
    orchestra.register( connection_1, player_1)
    connection_1.should_receive(:hear).with( 'player_id', "listens_for_1", 12.42)
    orchestra.play("listens_for_1", 12.42, 'player_id' )
  end

  it "fires players" do
    orchestra.register( connection_1, player_1 )
    orchestra.fire_player( id_1 )
    orchestra.players.has_key?( id_1 ).should be_false
  end

  it "should update plays when an event is sent" do
    orchestra.register( connection_1, player_1 )

    orchestra.play( "plays_3", 12.42, id_1 )
    orchestra.players[ id_1 ].plays?( "plays_3" ).should == true
    orchestra.events.include?( "plays_3" ).should == true
  end

  it "replaces existing registration with a new one" do
    orchestra.register( connection_1, player_1 )
    connection_1.should_receive( :terminate )
    orchestra.register( connection_2, player_1 )

    connection_1.should_not_receive(:hear)
    connection_2.should_receive(:hear).with( 'player_id', "listens_for_1", 12.42)
    orchestra.play("listens_for_1", 12.42, 'player_id')
  end

  it 'updates players last activity' do
    now = mock
    DateTime.stub( :now ).and_return( now )
    orchestra.register( connection_1, player_1 )
    orchestra.play( "plays_3", 12.42, id_1 )
    player_1.last_activity.should == now
  end

  it "tracks players" do
    orchestra.register( connection_1, player_1 )
    orchestra.players.size.should == 1
    orchestra.players[ id_1 ].should == player_1
    orchestra.players[ id_1 ].hears?("listens_for_1").should == true
    orchestra.players[ id_1 ].hears?("listens_for_2").should == true
    orchestra.players[ id_1 ].plays?("plays_1").should == true
    orchestra.players[ id_1 ].plays?("plays_2").should == true
  end

  it "lists events" do
    orchestra.register( connection_1, player_1 )
    orchestra.events.size.should == 4
    %w(listens_for_1 listens_for_2 plays_1 plays_2).each do |event|
      orchestra.event_names.include?(event).should be_true
    end
  end

  context 'Callbacks' do
    it "registers registration observers" do
      orchestra.on_register do |player|
        @callback_run = true
        player.should == player_1
      end

      orchestra.register(connection_1, player_1)
      @callback_run.should be_true
    end

    it "unregisters players" do
      orchestra.register( connection_1, player_1 )

      orchestra.on_unregister do |player|
        @callback_run = true
        player.should == player_1
      end

      orchestra.fire_player( id_1 )
      @callback_run.should be_true
    end

    it "registers event observers" do
      orchestra.register( connection_1, player_1 )

      orchestra.on_play do |name, value, player|
        @callback_run = true
        player.should == player_1
        name.should == "food"
        value.should == "bard"
      end

      orchestra.play("food", "bard", id_1)
      @callback_run.should be_true
    end
  end

  context "Spalla ID's and IP's" do
    before :each do
      orchestra.register( connection_1, player_1 )
      orchestra.register( connection_2, player_2 )
    end

    context "ID's" do
      it 'has Spalla ids' do
        orchestra.spalla_ids.should == [id_1, id_2]
      end

      it 'drops fired spallas' do
        orchestra.fire_player( id_1 )
        orchestra.spalla_ids.should == [id_2]
      end

      it 'has deployable spalla ids' do
        player_2.deployable?.should be_true
        orchestra.deployable_spalla_ids.should == [id_2]
      end
    end

    context "Players" do
      it 'has player addresses' do
        orchestra.players_for( [id_1, id_2] ).should == [player_1, player_2]
      end

      it 'drops fired players' do
        orchestra.fire_player( id_1 )
        orchestra.players_for( [id_1, id_2] ).should == [player_2]
      end

      it 'handles nil' do
        orchestra.players_for( nil ).should == []
      end
    end
  end
end
