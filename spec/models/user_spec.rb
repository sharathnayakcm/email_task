require 'spec_helper'

module User_data
  def data
    @user_a = create(:user,:first_name=>"aaa")
    @user_b = create(:user,:first_name=>"bbb")
    @chan_a = create(:channel,:user=>@user_a)
    @chan_b = create(:channel,:user=>@user_b)
    @buzz_a =  create(:buzz,:user=>@user_a,:channel=>@chan_a)
    create(:buzz,:user=>@user_b,:channel=>@chan_b)
    create(:subscription,:user =>@user_a,:channel=>@chan_a)
    create(:subscription,:user =>@user_b,:channel=>@chan_b)
  end
end
describe User do
  include User_data
  include ActionView::Helpers::DateHelper

  it { should have_many(:channels) }
  it { should have_one(:user_preference) }
  it { should have_many(:subscriptions) }
  it { should have_many(:channel_aliases) }
  it { should have_many(:buzzs) }
  it { should have_many(:watch_channels) }
  it { should have_many(:buzz_insyncs) }

  describe "#display_name" do
    it{ create(:user)
      should validate_uniqueness_of(:display_name)}
  end

  describe "#first_name" do
    it{should validate_presence_of(:first_name)}
  end


  describe "#last_name" do
    it{should validate_presence_of(:last_name)}
  end

  before(:all) do
    @ram = create(:user,:first_name=>"ram")
    @joe = create(:user,:first_name=>"joe")
    @joe1 = create(:user)
    @val_user = create(:user,:first_name=>"valuser")
    
    @chan2 = create(:channel,:name=>"ranchan",:user=>@ram)
    @chan3 = create(:channel,:name=>"ramesh",:user=>@joe)
    @cug = create(:channel,:name=>"ramcug",:user=>@joe,:is_cug=>true)
    @chan1 = create(:channel,:name=>"ram",:user=>@ram,:is_cug=>true)
    
    @sub1 = create(:subscription,:user =>@joe,:channel=>@chan3)
    @sub1 = create(:subscription,:user =>@ram,:channel=>@chan1,:is_core=>false)
    @sub2 = create(:subscription,:user =>@joe,:channel=>@cug)

    @buzz2 = create(:buzz,:user=>@joe,:channel=>@chan3)
    @buzz3 = create(:buzz,:user=>@joe,:channel=>@cug)
    @buzz1 = create(:buzz,:user=>@ram,:channel=>@chan3)
    @ram_buzz2 = create(:buzz,:user=>@ram,:channel=>@cug,:created_at=>Time.now-3.days)

    
    @watch_chan = create(:watch_channel,:user=>@joe,:channel=>@cug)
    @watch_chan = create(:watch_channel,:user=>@joe,:channel=>@chan2)
  end


  it "this will validate presence of display name or not" do
    @val_user.display_name = @ram.display_name
    @val_user.should have(1).error_on(:display_name)
  end


  it "this will validate presence of user id or not" do
    
    @val_user.first_name = nil
    @val_user.should have(1).error_on(:first_name)
  end

  it " validate  user id is numeric or  not" do
    @val_user.last_name = nil
    @val_user.should have(1).error_on(:last_name)
  end


  it "this will validate email format" do
    @val_user.email = "nil.com"
    @val_user.should have(2).error_on(:email)
  end


  #Validation Test case end


  it "returns use full name" do
    @sam =create(:user,:display_name =>{})
    @ram.full_name.should eql @ram.display_name.titleize
    @sam.full_name.should eql (@sam.first_name+ " " +@sam.last_name).titleize
  end
  
  it "returns admin status" do
    @admin = create(:user,:is_admin=> true)
    @admin.admin_status.should eql "Yes"
    @ram.admin_status.should eql "No"
  end


  it "checks user account status" do
    @sam =create(:user,:confirmed_at=>Time.now)
    @diva = create(:user,:confirmed_at=>nil )
    @diva.user_account_status.should eql "Not Verified"
  end

 
  it "actiavte the account" do
    @ram.activate.should eql true
  end
  
  context"#deactivate" do
    before{
      @man = create(:user)
    }
    it "actiavte the account" do
      @man.deactivate.should eql true
    end
  end

  it "returns my channel" do
    @sub1 = create(:subscription,:user =>@ram,:channel=>@chan2)
    @ram.my_channels.first.should eql @chan2
  end
  
  it "returns cug created by user" do
    @sam1 = create(:user)
    @ram.owner_cugs.should have(1).items
    @sam1.owner_cugs.should be_empty
  end

  
  context "returns new channels" do
    before{@rog = create(:user)
      create(:channel,:user=>@rog,:created_at=>Date.today - 3.days)
    }

    it {@rog.new_channels.first.should eql @chan3}
  end

  it "returns other channels" do
    @chan = create(:channel,:name=>"ramc1hann",:user=>@ram,:created_at=>Date.today.weeks_ago(1))
    @chan1 = create(:channel,:name=>"ramcug1",:user=>@ram)
    
    @ram.other_channels.first.should eql @chan
  end


 it "return user today channels buzzed" do
    @joe.today_channels_buzzed.should  have(1).items
  end

  it "not return user today channels buzzed" do
    @joe1.today_channels_buzzed.should be_empty
  end

  it "returns buzzed list of watched channel" do
    #channel_buzzes
    @watch_chan2 = create(:watch_channel,:user=>@joe,:channel=>@chan3)
    #@joe.watch_channels_buzzes.should eql true #([{:id=>@buzz3.id, :message=>@buzz3.message, :buzzed_by=>"You", :created_at=> time_ago_in_words(@buzz3.created_at).to_s+ ' ago', :name=>@cug.name, :channel_id=>@cug.id, :is_cug=>true, :insynced=>true, :priority=>nil},{:id=>@buzz2.id, :message=>@buzz2.message, :buzzed_by=>"You", :created_at=> time_ago_in_words(@buzz2.created_at).to_s+ ' ago', :name=>@chan3.name, :channel_id=>@chan3.id, :is_cug=>false, :insynced=>true, :priority=>nil}])
  end

  it "return the alias name of channel" do
    #channel_buzzes
    @alias = create(:channel_alias,:user=>@joe,:channel=>@chan3)
    @cug_alias = create(:channel_alias,:user=>@joe,:channel=>@cug)
    @joe.user_channel_aliases(false).all.should eql [@alias]
    @joe.user_channel_aliases(true).all.should eql [@cug_alias]
  end

  it "returns the new password" do
    Time.stub(:now).and_return(Date.today, Date.today - 1)
    old_password = @ram.new_random_password
    @ram.password
    new_password = @ram.new_random_password
    old_password.should_not eql new_password
  end

  describe "getting all CUGs method " do

    context "#core_cugs" do
      it{@joe.core_cugs.first.should eql @cug}
    end

    context "#peripheral_cugs" do
      it{@ram.peripheral_cugs.first.should eql @chan1}
    end

  end

  describe "returns user fav channel/cug" do
    context "#fav_channels" do
      it{@joe.fav_channels.first.should eql @ranchan}
    end

    context "#fav_cugs" do
      it{@joe.fav_cugs.first.should eql @cug}
    end    
  end

  describe "#subscribed_channels_tag_list" do
    before{
      @cug1 = create(:cug)
      create(:subscription,:user =>@joe,:channel=>@cug1)
      @pbuzz = create(:buzz,:user=>@joe,:channel=>@cug1)
      @buzz2 = create(:buzz,:user=>@joe,:channel=>@cug1)
      @tag1 = create(:tag,:name=>"tag1")
      @b_tag = create(:buzz_tag,:buzz=>@buzz2,:tag=>@tag1)
      @b_tag1 = create(:buzz_tag,:buzz=>@pbuzz)
    }

    context "presence of tag list for subscribed channel" do
      it{@joe.subscribed_channels_tag_list.first.should eql({:tag_id=>@b_tag.id, :tag_name=>" #{@tag1.name}"})}
    end

    context "absence of tag list for subscribed channel" do
      it{@joe1.subscribed_channels_tag_list.should be_empty}
    end
  end

  describe "#subscribed_channels_tag_list_by_name" do
    before{
      @cug1 = create(:cug)
      create(:subscription,:user =>@joe,:channel=>@cug1)
      @pbuzz = create(:buzz,:user=>@joe,:channel=>@cug1)
      @buzz2 = create(:buzz,:user=>@joe,:channel=>@cug1)
      @tag1 = create(:tag,:name=>"tag1")
      @b_tag = create(:buzz_tag,:buzz=>@buzz2,:tag=>@tag1)
      @b_tag1 = create(:buzz_tag,:buzz=>@pbuzz)
    }

    context "presence of tag name for subscribed channel" do
      it{@joe.subscribed_channels_tag_list_by_name("tag1").first.should eql @b_tag}
    end

    context "absence of tag name for subscribed channel" do
      it{@joe1.subscribed_channels_tag_list_by_name(@tag1).should be_empty}
    end
  end

  describe "subscribed_channels_subscribed_user_list" do
    before{
      @cug1 = create(:cug)
      create(:subscription,:user =>@joe,:channel=>@cug1)
      @buzz2 = create(:buzz,:user=>@joe,:channel=>@cug1)
    }
    
    context "subscribed_channels_subscribed_user_list" do
      it{@joe.subscribed_channels_subscribed_user_list.should have(1).items}
    end
  end

  describe "#get_cugs_unsync_count" do
    
    before{
      @sam = create(:user)
      @cugs = create_list(:channel,3,:user=>@sam)
    }
    it{
      Channel.any_instance(:stub).unsync_buzz_count.and_return(2,2,2)
      @sam.get_cugs_unsync_count(@cugs,true).should eql true
    }
  end

  describe "rake tasks methods " do
    before(:all) do
      @joe = create(:user)
      @user = create(:user,:first_name=>"ramu")
      @cug1 = create(:cug)
      @channel = create(:channel)
      create(:subscription,:user =>@joe,:channel=>@cug1)
      create(:subscription,:user =>@user,:channel=>@cug1)
      create(:subscription,:user =>@joe,:channel=>@channel)

      @pbuzz = create(:buzz,:user=>@joe,:channel=>@cug1)
    end

    context"#today_cugs" do
      before{
        @cug_s = create(:cug,:user =>@user,:name=>"second")
        create(:subscription,:user =>@joe,:channel=>@cug_s)
        create(:buzz,:user=>@user,:channel=>@cug_s)
      }
      it{
        @joe.today_cugs.first.should eql @cug_s
      }
    end
    
    context "#today_cugs_buzzed_me" do
      it{
        @joe.today_cugs_buzzed_me.first.should eql @cug1
      }
    end

    context "#priority_cugs" do
      before {
        @priority = create(:priority_buzz,:user=>@joe,:buzz=>@pbuzz,:insync=>false)
      }
      it{
        @joe.priority_cugs.first.should eql @cug1
      }
    end

    context "#responce_expected_cugs" do
      before{
        @response_buzz = create(:response_expected_buzz,:user=>@joe,:buzz=>@pbuzz)
      }
      it{
        @joe.responce_expected_cugs.first.should eql @cug1
      }
    end

    context"#awaiting_responses_cugs" do
      before{
        @buzz = create(:buzz,:user=>@user,:channel=>@cug1)
        @awaiting_response_buzz = create(:response_expected_buzz,:user=>@joe,:buzz=>@buzz,:owner_id =>@user.id)
      }
      it{
        @user.awaiting_responses_cugs.first.should eql @cug1
      }
    end

    context "#dormant_cugs" do
      before{
        @j_cug = create(:cug,:user=>@joe,:created_at => 3.days.ago)
        create(:subscription,:user =>@joe,:channel=>@j_cug)
      }
      it{
        @joe.dormant_cugs.first.should eql @cug1
      }
    end

    context "#normal_cugs" do
      before{
        @nor_cug = create(:cug,:user=>@user)
        create(:subscription,:user =>@joe,:channel=>@nor_cug)
      }
      it{
        @joe.normal_cugs.first.should eql @cug_s
      }
    end

    context "#channel_buzz_count" do
      before{
        create(:buzz,:user=>@user,:channel=>@cug1)
      }

      it{
        @joe.channel_buzz_count(@cug1).should eql 1
      }
    end

    context "#today_channels_buzzed" do
      before{
        create(:buzz,:user=>@user,:channel=>@channel)
      }

      it{
        @joe.today_channels_buzzed.first.should eql @channel
      }
    end

    context"#get_buzz_insyncs" do
      before{
        @buzzs = create(:buzz,:user=>@user,:channel=>@channel)
        @buzz_in = create(:buzz_insync, :buzz=>@buzz, :user=>@user, :channel=>@channel)
      }

      it{
        @user.get_buzz_insyncs(@channel).should eql @buzz_in
      }
    end


    context""
  end

end


