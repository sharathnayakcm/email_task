require 'spec_helper'
=begin
### method which are not used any where in code
def moderator_id=(value)
=end
describe Channel do
  include ActionView::Helpers::DateHelper
  it { should belong_to(:user) }
  it { should have_many(:channel_aliases) }
  it { should have_many(:subscriptions) }
  it { should have_many(:tags) }
  it { should have_many(:buzzs) }
  it { should have_many(:watch_channels) }
  it { should have_many(:buzz_insyncs) }
  it { should have_many(:channel_associations) }

  describe '#name' do
    it { should validate_presence_of(:name) }
    it{ should allow_value('Channel12').for(:name) }
    it{ should_not allow_value('@#Channel-12').for(:name) }
    it{ should_not allow_value('Channel_12').for(:name) }
  end

  describe '#moderator_id' do
    before {
      @user1 = create(:user)
      @channel = create(:channel, :user => @user1)
    }

    it{@channel.moderator_id.should be_eql @user1.id}

  end

  describe '#moderator_name' do
    before {
      @user1 = create(:user)
      @user2 = create(:user)
      @channel = create(:channel, :user => @user1)
    }
    context "when current user is moderator" do
      it{@channel.moderator_name(@user1).should be_eql 'You' }
    end

    context "when user is not moderator" do
      it{@channel.moderator_name(@user2).should be_eql @user1.full_name }
    end

  end

  describe '#moderator' do
    before do
      @user = FactoryGirl.create(:user, :first_name =>'ramesh')
      @channel = FactoryGirl.create(:channel,:name=>"testchannel",:user=>@user)
    end
    it { @channel.moderator.should be_eql @user.full_name }
    it { @channel.moderator.should_not be_eql 'ramesh not'}
  end

  describe '#moderator?' do
    before(:all) { @channel = create(:channel)}
    it { @channel.moderator?(@channel.user).should be_eql 'You' }
    it { @channel.moderator?(build(:user)).should be_eql @channel.user.full_name }
  end

  describe '#subscribers' do
    before (:all) do
      @sub_user = create(:user)
      @not_sub_user = create(:user)
      @channel = create(:channel)
      @subscription = create(:subscription, :channel => @channel, :user => @sub_user)
    end

    it { @channel.subscribers.should be_eql [@sub_user.id] }
    it { @channel.subscribers.should_not be_eql [@not_sub_user.id] }
  end
  
  describe "#channel active?" do
    before :each do
      @open_channel = create(:channel)
      @closed_channel = create(:channel,:is_active=>false)
    end
    context "when native cahnnel is given" do
      it{@open_channel.status.should eql "Open"}
    end
    context "when channel is inactive "
    it{@closed_channel.status.should eql "Closed"}
  end

  describe "return created date" do
    before :each do
      @created_date = create(:channel,:name=>"date")
      @date = @created_date.created_at
    end

    it{@created_date.created_at.should eql @date}

  end

  describe "#check admin or not" do
    before :each do
      @user1 = create(:user)
      @user2 = create(:user)
      @channel = create(:channel, :user => @user1)
    end
    context "when admin user give " do
      it{@channel.is_admin?(@user1).should eql true}
    end
    context "when non-admin user give " do
      it{@channel.is_admin?(@user2).should eql false }
    end
  end

  describe "check user is owner or not" do
    before :each do
      @user1 = create(:user)
      @user2 = create(:user)
      @channel = create(:channel, :user =>@user1)
    end
    context "when channel owner is given" do
      it { @channel.is_owner?(@user1).should eql true }
    end
    context "when channel owner not is given" do
      it { @channel.is_owner?(@user2).should eql false }
    end
  end

  describe "return users who are subscribed to channels" do
    before :each do
      @user1 = create(:user)
      @channel_a = create(:channel,:name=>'test',:user=>@user1)
      create(:subscription,:user=>@user1,:channel=>@channel_a)
    end
    it{@channel_a.subscribers.should eql [@user1.id]}

  end

  describe "user is subscribed to channel or not" do
    before :each do
      @user1 = create(:user)
      @user2 = create(:user)
      @channel = create(:channel, :user => @user1)
      create(:subscription,:user=>@user1,:channel=>@channel)
    end
    context "when a user is subscribe to channel" do
      it{ @channel.is_subscribed?(@user1).should eql true}
    end
    context "when a user is not subscribed to channel" do
      it{ @channel.is_subscribed?(@user2).should eql false}
    end
  end

  describe "channel or CUG" do
    before :each do
      @channel1 = create(:channel,:is_cug => false)
      @channel2 = create(:channel,:is_cug => true)
    end
    context "when its a channel" do
      it {@channel1.channel_or_cug.should eql "Channel"}
    end
    context "when its a CUG" do
      it {@channel2.channel_or_cug.should eql "CUG"}
    end
  end

  describe "whether channel is watched by user or not" do
    before :each do
      @channel = create(:channel)
      @user = create(:user)
      @user1 = create(:user)
      create(:watch_channel,:user => @user,:channel => @channel)
    end
    context "when a user has watched a channel" do
      it {@channel.channel_in_watch?(@user).should eql true}
    end
    context "when a user has watched a channel" do
      it {@channel.channel_in_watch?(@user1).should eql false}
    end
  end

  describe "count channel buzz" do
    before :each do
      @channel = create(:channel)
      create(:buzz,:channel => @channel)
    end
    it{ @channel.channel_buzzes_count(7.days.ago).should eql 1 }
  end

  describe "cug_status" do
    before {
      @user_a = create(:user)
      @core_cug = create(:channel,:user=>@user_a)
      @peripheral_cug = create(:channel,:user=>@user_a)
      create(:subscription,:user=>@user_a,:channel=>@core_cug)
      create(:subscription,:user=>@user_a,:channel=>@peripheral_cug,:is_core=>false)
    }

    it{@core_cug.cug_status(@user_a).should eql "Core"}

    it{@peripheral_cug.cug_status(@user_a).should eql "Peripheral"}
  end

  describe "channel_members" do
    before {
      @user_a = create(:user)
      @core_cug = create(:channel,:user=>@user_a)
      @peripheral_cug = create(:channel,:user=>@user_a)
      create(:subscription,:user=>@user_a,:channel=>@core_cug)
      
    }

    it{@core_cug.channel_members.should eql [@user_a]}

    it{@peripheral_cug.channel_members.should eql []}

  end


  
  describe "adding alias to channel" do
    before :each do
      @msg = ["Alias has been added successfully."], true
      @user = create(:user)
      @channel = create(:channel,:user => @user)
    end
    context "if alias is successfully added" do
      it{ @channel.add_alias('aliaschannel',@channel,@user).should eql @msg }
    end

    
    it "if alias is not added" do
      ChannelAlias.any_instance.stub(:save).and_return(false)
      @channel.add_alias('alia',@channel,@user).should_not eql @msg
    end
  end
  
  describe "return number of scubscribers" do
    before :each do
      @user1 = create(:user)
      @chan_x = create(:channel,:name=>'test',:user=>@user1)
      create(:subscription,:user=>@user1,:channel=>@chan_x)
      create(:buzz,:user=>@user1,:channel=>@chan_x)
    end
    it{@chan_x.buzzers.should eql 1}
  end

  describe "return number of buzzers" do
    before :each do
      @channel_chan = create(:channel)
      @buzzers = Subscription.select(:user_id).where(:channel_id => @channel_chan.id).map(&:user_id).count
    end
    it {@channel_chan.buzzers.should eql @buzzers}
  end


  describe "get users last viewed channel" do
    before :each do
      @user = create(:user)
      @channel_chan = create(:channel)
      @sub = create(:subscription,:user =>@user,:channel=>@channel_chan)
    end
    it{ @channel_chan.get_channel_last_viewed(@user).first.to_s.should eql @sub.last_viewed.to_s }
  end
  
  describe "retuen the list of tags" do
    before :each do
      @channel = create(:channel)
    end
    it{@channel.tag_list.should eql ""  }
  end

  describe "remove alias channel "  do
    before :each do
      @ramesh = create(:user)
      @fun = create(:channel,:name=>"funny",:user=>@ramesh)
      @chan = create(:channel_alias,:name=>"funalias",:user=>@ramesh,:channel=>@fun)
    end
    it{Channel.remove_channel("alias","funalias", false,@ramesh).should eql [["Channel #{@fun.name} removed successfully."],true]}
  end
  

  describe " Name has already taken error must raise "  do
    before :each do
      @user =create(:user)
      @chan_name = Channel.first.name.split
    end
    it {Channel.add_channels(@chan_name,  @user,false).should eql [["$Name has already been taken"],false]}
  end

  describe "Add channels " do
    before :each do
      @user =create(:user)
      @chan_name = ["name1","name2","name3"]
    end
    it { Channel.add_channels(@chan_name, @user,false).should eql [["Channel name1, name2, name3 added successfully"],true] }
  end

  # associated_channels is not in use

  #  describe "This is give associated channels " do
  #    before :each do
  #      @user = create(:user)
  #      @channel_chan = create(:channel)
  #      @cug = create(:channel,:name=>"sampug",:user=>@user,:is_cug=>true)
  #      @chan_ass = ChannelAssociation.create(:channel_id=>@channel_chan.id,:cug_id=>@cug.id)
  #    end
  #    it{ @cug.associated_channels[0].should eql @chan_ass }
  #  end

  describe "remove alias channel " do
    before :each do
      @ramesh = create(:user)
      @fun = create(:channel,:name=>"funny",:user=>@ramesh)
      @chan = create(:channel_alias,:name=>"funalias",:user=>@ramesh,:channel=>@fun)
    end
    it {Channel.remove_channel("alias","funalias", false,@ramesh).should eql [["Channel #{@fun.name} removed successfully."],true]}
  end


  describe "remove the channel " do
    before :each do
      @ramesh = create(:user)
      @suresh = create(:user)
      @channel_chan = FactoryGirl.create(:channel,:name=>"testchannel",:user=>@ramesh)
    end
    it{Channel.remove_channel("channel", "testchannel", false,@ramesh).should eql [["Channel testchannel removed successfully."],true]}
    it{Channel.remove_channel("channel", "testchannel", false,@suresh).should eql [["Only Admin/ Owner of Channel testchannel can remove a Channel"],false]}
    it{Channel.remove_channel("channel", "test", false,@suresh).should eql [["Channel doesn't exist or is inactive."], false]}
  end

  describe "returns user last sync buzz id " do
    before :each do
      @ramesh = create(:user)
      @channel = create(:channel, :user => @ramesh)
      @buzz = create(:buzz,:message=>"beehive search word",:user=>@ramesh, :channel=>@channel)
      @sync1 = create(:buzz_insync,:user=>@ramesh,:channel=>@channel,:buzz_id=>@buzz)
    end
    it{ @channel.get_channel_last_insynced_buzz_id(@ramesh).should eql 1 }
  end

  describe "This will return save sync time when it was sync" do
    before :each do
      @ramesh = create(:user)
      @channel = create(:channel, :user => @ramesh)
      @sub = create(:subscription,:user =>@ramesh,:channel=>@channel)
    end
    it{ @channel.set_last_viewed(@ramesh).should eql true }
  end

  # associated_channels is not in use

  #  describe "This will give associated channels " do
  #    before :each do
  #      @ramesh = create(:user)
  #      @channel = create(:channel, :user => @ramesh)
  #      @cug = create(:channel,:name=>"sampug",:user=>@ramesh,:is_cug=>true)
  #      @chan_ass = ChannelAssociation.create(:channel_id=>@channel.id,:cug_id=>@cug.id)
  #    end
  #    it {@cug.associated_channels[0].should eql @chan_ass}
  #  end
  #
  describe "returns active buzzers" do
    before :each do
      @ramesh = create(:user)
      @channel = create(:channel, :user => @ramesh)
      @buzz = create(:buzz,:message=>"beehive search word",:user=>@ramesh, :channel=>@channel)
    end
    it {@channel.active_buzzers.should eql 1}
  end

  describe ".limit_user and is_subscribed?" do
    before :each do
      @user_a = create(:user)
      @user_b = create(:user)
      @channel = create(:channel)
      create(:subscription,:user=>@user_a,:channel=>@channel)
    end
    context "@channel limit users" do
      it{@channel.limit_user.should eql [@user_a]}
    end

    context "is @user_a subscribed to channel @channel" do
      it {@channel.is_subscribed?(@user_a).should eql true}
    end

    context "is @user_b subscribed to channel @channel" do
      it {@channel.is_subscribed?(@user_b).should eql false}
    end
  end

  describe "#core cug" do
    before {
      @user_a = create(:user)
      @user_b = create(:user)
      @core_cug = create(:channel,:user=>@user_a)
      @peripheral_cug = create(:channel,:user=>@user_a)
      create(:subscription,:user=>@user_a,:channel=>@core_cug)
      create(:subscription,:user=>@user_b,:channel=>@peripheral_cug,:is_core=>false)
    }

    context "for @user_a  core cug" do
      it{@core_cug.is_core?(@user_a).should eql true}
    end

    context "when Peripheral cug type is given" do
      it{@peripheral_cug.change_cug_type(@user_b,"core").should eql "Your involvement in this CUG changed to Peripheral"}
    end

    context "when core cug type is given" do
      it{@core_cug.change_cug_type(@user_a,"switch to peripheral").should eql "Your involvement in this CUG changed to Core"}
    end
    
  end

  describe ".is_admin?" do
    before{
      @user = create(:user)
      @user_a = create(:user)
      @channel = create(:channel,:user=>@user)
    }

    context" when channel admin is given" do
      it{Channel.is_admin?(@channel.id,@user).should eql true}
    end

    context" when channel admin is given" do
      it{Channel.is_admin?(@channel.id,@user_a).should eql false}
    end

  end

  describe "channel_description" do
    before{
      @channel = create(:channel,:user=>@user)

    }

    it "when description is given" do
      @channel.channel_description.should eql @channel.description
    end

    it "when description is not given" do
      @channel.description = nil
      @channel.channel_description.should eql "No description found."
    end
  end

  describe"type buzzers" do
    before {
      @user_a = create(:user)
      @core_cug = create(:channel)
      create(:subscription,:user=>@user_a,:channel=>@core_cug)
      create(:subscription,:channel=>@core_cug)
      create(:subscription,:channel=>@core_cug,:is_core=>false)
    }

    it{@core_cug.type_buzzers(true).should eql 2}

    it{@core_cug.type_buzzers(false).should eql 1}
  end


  describe "sync users" do
    before {
      @user_a = create(:user)
      @user_b = create(:user)
      @core_cug = create(:channel)
      @peripheral_cug = create(:channel,:user=>@user_a)
      create(:subscription,:user=>@user_a,:channel=>@core_cug)
      create(:subscription,:channel=>@core_cug,:user=>@user_b)
      create(:subscription,:user=>@user_a,:channel=>@peripheral_cug,:is_core=>false)

    }

    context"no of sync_core_users " do
      it{@core_cug.sync_core_users.should eql "(#{@user_a.full_name}, #{@user_b.full_name})"}
    end

    context"no of sync_peripheral_users " do
      it{@peripheral_cug.sync_peripheral_users.should eql "(#{@user_a.full_name})"}
    end
    
    context "buzzers_list" do

      it"core cug" do
        @core_cug.buzzers_list.should have(2).items
      end

      it"periheral cug" do
        @peripheral_cug.buzzers_list(false).should have(1).items
      end
    end
   
  end

  describe "total buzzes and buzz_count" do
    before{
      @channel = create(:channel,:name=>"chan1")
      create(:channel,:name=>"chan2")
      create(:buzz,:channel=>@channel)
      create(:buzz,:channel=>@channel)
      create(:buzz,:channel=>@channel)
      create(:buzz,:channel=>@channel,:created_at=>Time.now - 2.days)
    }

    context "buzz_count" do
      it{@channel.buzz_count([@channel],Time.now - 1.days).first.values_at(:id,:name,:buzz_count).should eql [@channel.id,@channel.name,3]}
    end
    
    context "total buzzes of channel" do
      it{@channel.total_buzzes.should eql 4}
    end

    context "todays buzz count of channel" do
      it{@channel.today_buzzes_count.should eql 3}
    end

    describe "buzz count based on buzz rate" do

      context "for buzz rate 24" do
        it{@channel.buzz_rate_count(24).should eql 3}
      end

      context "for buzz rate 72 " do
        it{@channel.buzz_rate_count(72).should eql 4}
      end
    end

  end

  describe "search class methods" do
    before {
      @ramesh = create(:user,:first_name =>'ramesh')
      @admin = create(:admin)
      @channel = create(:channel,:name=>"testchannel",:user=>@ramesh)
      @alias = create(:channel_alias,:user=>@ramesh,:channel=>@channel)
      create(:subscription,:user=>@ramesh,:channel=>@channel)
      create(:buzz,:message=>"this is test buzz",:user=>@ramesh,:channel=>@channel)
      create(:buzz,:message=>" someone can be done test buzz")
      @cug = create(:channel,:name=>"comcug",:user=>@ramesh,:is_cug=>true)
      create(:buzz,:message=>"what can we buzz for cug",:channel=>@cug)
      create(:subscription,:user=>@ramesh,:channel=>@cug)
    }
    
    context "search for the channels with text testchannel" do
      it{Channel.all_channels_search("testchannel",false, @ramesh).should have(1).items}
    end
    
    context "search for the cug with text comcug" do
      it{Channel.all_channels_search("comcug",true, @ramesh).should have(1).items}
    end

    # *   context ".find_buzz" do
    #      it{Channel.find_buzz("test",@ramesh).should have(2).items}
    #    end

    #Need to be checked

    #    describe ".buzz_channels_search" do
    #      context "when search_channel_name is channel name" do
    #        it {Channel.buzz_channels_search("test",false, false,@channel.name,@ramesh).should have(1).items}
    #      end
    #
    #      context "when search_channel_name is alias channel name" do
    #        it {Channel.buzz_channels_search("test",false, true,@alias.name,@ramesh).should have(1).items}
    #      end
    #
    #      context "when search_channel_name is my " do
    #        it {Channel.buzz_channels_search("test",false,false,'my',@ramesh).should have(1).items}
    #      end
    #
    #      context "when search_channel_name is my " do
    #        it {Channel.buzz_channels_search("test",false,false,'all',@ramesh).should have(2).items}
    #      end
    #    end
    #
    #    describe ".buzz_channels_cugs_search" do
    #      context "when user is not admin" do
    #        it{Channel.buzz_channels_cugs_search("can",@ramesh).should have(1).items}
    #      end
    #
    #      # *     context "when user is admin" do
    #      #        it{Channel.buzz_channels_cugs_search("can",@admin).should have(1).items}
    #      #      end
    #
    #    end

  end

  # Today and buzz rate functionalities no more exits
  describe "#buzzes list" do

    before {
      @ramesh = create(:user)
      @channel = create(:channel,:name=>"testchannel",:user=>@ramesh)
      create(:buzz,:user=>@ramesh,:channel=>@channel)
      create(:buzz,:channel=>@channel)
      create(:buzz,:channel=>@channel,:created_at=>Time.now - 2.days)
      create(:buzz,:channel=>@channel,:created_at=>Time.now - 3.days)
    }

    context " when criteria is buzz_rate " do
      it{@channel.buzzes_list(@ramesh,'Buzz_Rate_1').should be true}
    end

    context "when criteria is buzz_rate " do
      it{@channel.buzzes_list(@ramesh,'Buzz_Rate_2').should have(3).items}
    end

    context "when criteria is Today " do
      it{@channel.buzzes_list(@ramesh,'Today').should have(2).items}
    end

    context " when criteria is by data " do
      it{@channel.buzzes_list(@ramesh, 'By_Date',Time.now - 4.days,Time.now).should have(4).items}
    end

  end

  describe "insync buzz" do
    before {
      @ramesh = create(:user)
      @ram = create(:user)
      @cug = create(:cug,:name=>"testchannel",:user=>@ramesh)
      @buzz = create(:buzz,:user=>@ramesh,:channel=>@cug)
      create(:buzz_insync,:user=>@ramesh,:channel=>@cug,:buzz_id=>@buzz)
      create(:buzz_insync,:user=>@ram,:channel=>@cug,:buzz_id=>@buzz)
    }

    context"no of insync buzz in channel" do
      it{@cug.insync_cug_stats.should have(2).items}
    end
  end

  describe ".get_channel" do
    before {
      @chan_1 = create(:channel,:name=>"onechannel")
      @chan_2 = create(:channel,:name=>"twochannel")
      @samp = create(:channel,:name=>"sampchannel")
      @alias_chan = create(:channel_alias,:name=>"chanalias",:channel=>@samp)
    }

    context "when channel name is given" do
      it{Channel.get_channel("onechannel","",false).should eql @chan_1}
    end

    context "when channel name is given" do
      it{Channel.get_channel("chanalias","alias",false).should eql @samp}
    end


  end

  describe "toggle_watch" do
    before {
      @user = create(:user)
      @channel = create(:channel)
    }
    context "watch the channel" do
      it{@channel.toggle_watch(@user,"watch").should eql ["Channel #{@channel.name} has been added to your watch list"]}
    end

    context "unwatch the channel" do
      before{ create(:watch_channel,:channel=>@channel,:user=>@user)}
      it{@channel.toggle_watch(@user,"unwatch").should eql "Channel #{@channel.name} has been removed from your watch list"}
    end

  end

  describe ".add_channel and cug" do
    before{
      @user = create(:user)
      @channel = create(:channel)
    }

    context "success case" do
      it{expect{Channel.add_channel({"name"=>"sdgfddfsdfgsdf", "command"=>"this is buzz msg"},@user)}.to change(Channel,:count).by(1)}
    end

    context "when space is given in name" do
      it{Channel.add_channel({"name"=>"sdgfddf sdfgsdf", "command"=>"this is buzz msg"},@user).first.should eql ["$Name should be alphanumeric only"]}
    end

    context "when blank name is given " do
      it{Channel.add_channel({"name"=>" ", "command"=>"this is buzz msg"},@user).second.should eql false}
    end

    context "success case for cug" do
      it{expect{Channel.add_cug_channel({"name"=>"sdgfddfsdfgsdf", "command"=>"this is buzz msg"},@user)}.to change(Channel,:count).by(1)}
    end

    context "failure case for cug" do
      it{Channel.add_cug_channel({"name"=>"sdgfdd fsdfgsdf", "command"=>"this is buzz msg"},@user).first.should eql ["$Name should be alphanumeric only"] }
    end

    context "when blank name is given " do
      it{Channel.add_cug_channel({"name"=>" ", "command"=>"this is buzz msg"},@user).second.should eql false}
    end

  end

  describe "#save_cug_members" do
    before{
      @user1 = create(:user)
      @channel = create(:channel, :user => @user1)
    }
    it {
      expect{ @channel.save_cug_members("14,1,23,") }.to change{Subscription.count}.by(3)
    }
  end

  describe "#last_insynced_id" do
    before{
      @user1 = create(:user)
      @user2 = create(:user)
      @channel = create(:channel, :user => @user1)
      @buzz = create(:buzz, :user=>@user1, :channel=>@channel,:message =>"this is first buzz")
      create(:buzz, :user=>@user2, :channel=>@channel)
      create(:buzz, :user=>@user2, :channel=>@channel)
      create(:buzz, :user=>@user2, :channel=>@channel)
      @buzz_in = create(:buzz_insync, :buzz=>@buzz, :user=>@user1, :channel=>@channel)
    }

    it{
      @channel.last_insynced_id(@user1).should be_eql @buzz.id
    }

    context "#unsync_buzz_count" do
      it{
        @channel.unsync_buzz_count(@user1).should eql 3
      }
    end

    context "#not_viewed_channel_buzzs_count" do
      it{
        @channel.not_viewed_channel_buzzs_count(@user1).should eql 3
      }
    end
  end

  describe "search methods" do
    before{
      @ramesh = create(:user)
      @channel = create(:channel,:name=>"testchannel",:user=>@ramesh)
      for i in 0..3 do
        create(:buzz,:user=>@ramesh,:channel=>@channel)
      end
    }

    context "buzz_channels_cugs_search" do
      it{ Channel.get_buzzs(@channel.id,@ramesh,false).should have(4).items}
    end

    context "get_channel_buzzs" do
      it{Channel.get_channel_buzzs(@channel).should have(4).items}
    end

  end

  describe "advance search in channels" do
    before{
      @ramesh = create(:user)
      @ram = create(:user)
      @channel = create(:channel,:user=>@ramesh)
      create(:subscription,:user=>@ram,:channel=>@channel)
      @buzz_s = create(:buzz,:message=>"we can search this word also",:channel=>@channel,:user=>@ram)
      @buzz_r = create(:buzz,:message=>"what is  search word also",:channel=>@channel,:user=>@ram)
    }

    context "when search word is present" do
      it{Channel.advance_search_in_channel_buzzes({ :beehive_search=>{:channel_id=>@channel.id, :search_type=>"simple", :is_cug=>"false", :search_keyword=>"search"}},@ram,1).first[:buzzs].should include(@buzz_r,@buzz_s)}
    end

    context "when search word is not present" do
      it{Channel.advance_search_in_channel_buzzes({ :beehive_search=>{:channel_id=>@channel.id, :search_type=>"simple", :is_cug=>"false", :search_keyword=>"beehive"}},@ram,1).first[:buzzs].should be_empty}
    end
  end

  describe "subscribe methods " do
    before {
      @ramesh = create(:user)
      @ram = create(:user)
      @channel = create(:channel)
      create(:subscription,:user=>@ramesh,:channel=>@channel)
    }


    it" when unsubscribed user is not subscribe " do
      @channel.unsubscribe_self(@ram).should eql "$Sorry, You are not subscribed to Channel #{@channel.name}"
    end

    it "sucessfully unsubcribed" do
      @channel.unsubscribe_self(@ramesh).should eql "You have been unscubscribed successfully from Channel #{@channel.name}"
    end
  end



  # uncomment it to check trimmed_name method only

  #  describe "trimmed_name" do
  #    before {
  #      #@channel = create(:channel,:name=>"channelnamechannelnamechannelname")
  #    }
  #
  #    it {@channel.trimmed_name.should eql "channelnamechannelnamecha..."}
  #  end
end