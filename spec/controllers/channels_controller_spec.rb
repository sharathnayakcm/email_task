require 'spec_helper'

describe ChannelsController do
  login_user

  before {
    @user = subject.current_user
    @chan = create(:channel,:user=>@user)
    @chan1 = create(:channel)
    @buzz = create(:buzz,:user=>@user,:channel=>@chan)
  }

  describe "#new" do
    context"asssign channel should be new" do
      it{
        get :new,:format =>:js
        assigns[:channel].should be_a_new(Channel)}
    end
  end

  describe "Get create" do
  
    it{
      expect {
        post :create,:channel=> {"name"=>"cmchannel", "is_cug"=>"false", "buzzs_attributes"=>{"0"=>{"user_id"=>"#{@user.id}", "message"=>"dsfgdsf gsdfgd fgdsf gdsfg sdfg dsf"}}},:format =>:js
      }.to change(Channel, :count).by(1)
    }

    it "check the flash notice after create" do
      Channel.any_instance.stub(:save).and_return(true)
      post :create,:channel=> {"name"=>"cmchannel", "is_cug"=>"false", "buzzs_attributes"=>{"0"=>{"user_id"=>"#{@user.id}", "message"=>"dsfgdsf gsdfgd fgdsf gdsfg sdfg dsf"}}},:format =>:js
      flash[:notice].should include("added successfully")
    end

    it "Fail case must render" do
      Channel.any_instance.stub(:save).and_return(false)
      post :create,:channel=> {"name"=>"cmchannel", "is_cug"=>"false"},:format =>:js
      flash[:notice].should be_nil
    end

  end

  
  describe "Get get_channels" do
     context"when view has children" do
      it{
        get :get_channels ,:channel_view_type => "5",:format => :js
        assigns[:channels].first[:beehive_view_name].should eql "Channels Buzzed By Me"
      }
    end

    context"when view has ancestry" do
      it{
        get :get_channels ,:channel_view_type => "15",:format => :js
        assigns[:channels].first[:beehive_view_name].should eql "Channels Buzzed By Me"
      }
    end

    context"when view has no children and ancestry" do
      it{
        get :get_channels ,:channel_view_type => "1",:format => :js
        assigns[:channels].first[:beehive_view_name].should eql "My Channels"
      }
    end

    
  end


  describe "Get buzzes" do
    before{
      @buzzs = []
      for i in 0..3
        @buzzs << create(:buzz,:channel=>@chan)
      end
      User.any_instance.stub(:buzzs).and_return(@buzzs)
      get :buzzes,:id=>@chan.id,:format=>:js
    }

    it "check the var channel" do
      assigns[:channel].should eql @chan
    end

    it "checking the var buzzs" do
      assigns[:buzzs].first.should eql @buzzs.last
    end
    
  end

  describe "Get sub_unsub_channel" do
    before{
      @chan2 = create(:channel)
      create(:subscription,:user =>@user,:channel=>@chan2)
    }

    it "subscribe channel" do
      get :sub_unsub_channel,:channel_id=>@chan1.id,:act=>'subscribe',:format=>:js
      assigns[:action_status].should eql true
      assigns[:message].first.should eql "You have been subscribed successfully to Channel  #{@chan1.name}"
    end

    it "unsubcribe channel" do
      get :sub_unsub_channel,:channel_id=>@chan2.id,:act=>'unsubscribe',:format=>:js
      assigns[:message].first.should eql "You have been successfully unsubscribed from Channel #{@chan2.name}"
    end
    
  end

  describe "Get edit" do
    before{
      @chan2 = create(:channel)
      @sub2 = create(:subscription,:user =>@user,:channel=>@chan2)
    }

    it "find the subcribed object" do
      get :edit,:id=>@chan2.id,:format=>:js
      assigns[:subscription].should eql @sub2
    end
  end

  describe "Put update" do
    before{
      @chan2 = create(:channel)
      @sub2 = create(:subscription,:user =>@user,:channel=>@chan2)
      @alias = create(:channel_alias,:name=>"aliasfi",:user =>@user,:channel=>@chan1)
    }
    context  "Unsubscribe user" do
      it {
        expect{
          put :update,:id=>@chan2.id,:unsubscribe=>true,:fav_manage_mode=>'no',:aliase_name=>"",:format=>:js
        }.to change(Subscription,:count).by(-1)
      }
    end

    it "adding new alies name" do
      expect{
        put :update,:id=>@chan2.id,:fav_manage_mode=>'no',:aliase_name=>"aliaschan",:format=>:js
      }.to change(ChannelAlias,:count).by(1)
    end

    it " updating alias name" do
      put :update,:id=>@chan1.id,:fav_manage_mode=>'no',:aliase_name=>"aliaschan",:format=>:js
      assigns[:alias_msg].should be_empty
    end

    it "delete alias name" do
      expect{
        put :update,:id=>@chan1.id,:fav_manage_mode=>'no',:aliase_name=>" ",:format=>:js
      }.to change(ChannelAlias,:count).by(-1)
    end

    it " adding channel to favorite" do
      expect{
        put :update,:id=>@chan1.id,:fav_manage_mode=>'yes',:aliase_name=>"aliaschan",:format=>:js
      }.to change(WatchChannel,:count).by(1)

    end
  end

  describe "Get unsubscribe_self" do
    before{
      @chan2 = create(:channel)
      @sub2 = create(:subscription,:user =>@user,:channel=>@chan2)
    }
    
    it {
      expect{
        put :unsubscribe_self,:id=>@chan2.id,:unsubscribe=>true,:fav_manage_mode=>'no',:aliase_name=>"",:format=>:js
      }.to change(Subscription,:count).by(-1)
    }
  end
  
end
