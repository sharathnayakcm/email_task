require 'spec_helper'

describe BuzzsController do
  login_user

  before {
    @user = subject.current_user
    @user_a = create(:user,:first_name=>"sahana")
    @user_b = create(:user,:first_name=>"chaithanya")

    @chan = create(:channel,:user=>@user)

    @buzz = create(:buzz,:user=>@user,:channel=>@chan)
    
    @buzz_name = create(:buzz_name,:buzz=>@buzz,:user=>@user)
  }

  describe "Get index" do
    context" when cug is passed" do
      before {
        @cug = create(:cug,:user=>@user)
        @cug_buzzs = []

        for i in 0..3
          @cug_buzzs << create(:buzz,:user=>@user,:channel=>@cug)
        end
      }
      it{
        get :index, :channel_id => @cug.id, :format=>:js
        Channel.stub(:get_buzzs).and_return(@cug_buzzs.reverse!)
        assigns[:buzzs].first.should eql @cug_buzzs.first
      }
    end

  

    context" when channel is passed" do
      before {
        @channel_buzzs = []
        for i in 0..3
          @channel_buzzs << create(:buzz,:user=>@user,:channel=>@chan)
        end
      }
      it{
        get :index, :channel_id => @chan.id, :format=>:js
        Channel.stub(:get_channel_buzzs).and_return(@channel_buzzs.reverse!)
        assigns[:buzzs].first.should eql @channel_buzzs.first
      }
    end
  end

  describe "Get more_buzzs" do
    context "when cug is passed variable buzzs should contain remaining buzzs" do
      before {
        @cug = create(:cug,:user=>@user)
        @cug_buzzs = []

        for i in 0..3
          @cug_buzzs << create(:buzz,:user=>@user,:channel=>@cug)
        end
      }
      it{
        Channel.stub(:get_buzzs).and_return(@cug_buzzs.reverse!)
        get :more_buzzs,:id => @cug.id,:format =>:js
        assigns[:buzzs].first.should eql @cug_buzzs.first
      }
    end

    context "when Channel is passed variable buzzs should contain remaining buzzs" do
      before {
        @channel_buzzs = []

        for i in 0..3
          @channel_buzzs << create(:buzz,:user=>@user,:channel=>@chan)
        end
      }
      it{
        Channel.stub(:get_buzzs).and_return(@channel_buzzs.reverse!)
        get :more_buzzs,:id => @chan.id,:format =>:js
        assigns[:buzzs].first.should eql @channel_buzzs.first
      }
    end

  end
  
  describe "Get Show" do
    context "checking the assign variables" do
      it {
        get :show,:id=> @buzz.id,:channel_id=>@chan.id, :format=>:js
        assigns[:buzz].should eql @buzz
        assigns[:channel].should eql @chan
      }
    end
  end

  describe "Get New" do
    it "should return new Buzz object" do
      get :new,:format=>:js
      assigns[:buzz].should be_a_new(Buzz)
    end
  end


  describe "Get create" do
    before{
      @unsub_chan = create(:channel,:user=>@user_a)
    }
    
    it"should create new user"do
      expect {
        post :create, :buzz =>{"channel_id"=>@chan.id, "message"=>"svfsdf sdf sdf sadf ", "is_richtext_editor"=>"false"},:format=>:js
      }.to change(Buzz, :count).by(1)
    end

    it "check the flash after successfull create of buzz" do
      Buzz.any_instance.stub(:save).and_return(true)
      post :create,:buzz =>{"channel_id"=>@chan.id},:format=>:js
      flash[:notice].should include "Buzzed out to Channel \"#{@chan.name}\" successfully"
    end

    it "when channel is not found then flash error must be" do
      post :create, :buzz => {"message"=>"svfsdf sdf sdf sadf ", "is_richtext_editor"=>"false"},:format=>:js
      flash[:error].should eql "Channel or CUG doesn't exit, please select appropriate one."
    end
    
    it "when user is not admin or subscribed to channel then flash error must be" do
      post :create, :buzz => {"channel_id"=>@unsub_chan.id,"message"=>"svfsdf sdf sdf sadf ", "is_richtext_editor"=>"false"},:format=>:js
      flash[:error].should eql "You must be subscribed to or owner of the Channel #{@unsub_chan.name}"
    end

    it "save buzz properties (Priority Buzz)" do
      expect{
        post :create, :buzz =>{"channel_id"=>@chan.id, "message"=>"svfsdf sdf sdf sadf ", "is_richtext_editor"=>"false"},:prioritize_user_ids =>["3", "4"],:format=>:js
      }.to change(PriorityBuzz,:count).by(2)
    end

    it "save buzz properties (Response Expected Buzz)" do
      expect{
        post :create, :buzz =>{"channel_id"=>@chan.id, "message"=>"svfsdf sdf sdf sadf ", "is_richtext_editor"=>"false"},:response_expected =>{"0"=>{"expiry_date"=>""}, "1"=>{"user_id"=>"21", "expiry_date"=>"28-Nov-2012"}, "2"=>{"user_id"=>"3", "expiry_date"=>"28-Nov-2012"}, "3"=>{"expiry_date"=>""}},:format=>:js
      }.to change(ResponseExpectedBuzz,:count).by(2)
    end

    it "save buzz properties (Limit Users buzz)" do
      expect{
        post :create, :buzz =>{"channel_id"=>@chan.id, "message"=>"svfsdf sdf sdf sadf ", "is_richtext_editor"=>"false"},:user_ids=>["21", "3"],:format=>:js
      }.to change(BuzzMember,:count).by(3)
    end

    it "save buzz properties (Buzz Name)" do
      expect{
        post :create, :buzz =>{"channel_id"=>@chan.id, "message"=>"svfsdf sdf sdf sadf ", "is_richtext_editor"=>"false"},:buzz_name =>{"name"=>"some", "user_id"=>"19"},:format=>:js
      }.to change(BuzzName,:count).by(1)
    end

    it "save buzz properties (Buzz Flag)" do
      expect{
        post :create, :buzz =>{"channel_id"=>@chan.id, "message"=>"svfsdf sdf sdf sadf ", "is_richtext_editor"=>"false"},:buzz_flag =>{"0"=>{"flag_id"=>"2", "expiry_date"=>"30-Nov-2012"}, "1"=>{"flag_id"=>"3", "expiry_date"=>"29-Nov-2012"}, "2"=>{"expiry_date"=>""}, "3"=>{"expiry_date"=>""}, "4"=>{"expiry_date"=>""}},:format=>:js
      }.to change(BuzzFlag,:count).by(2)
    end

    it "save buzz properties (Buzz tag)" do
      expect{
        post :create, :buzz =>{"channel_id"=>@chan.id, "message"=>"svfsdf sdf sdf sadf ", "is_richtext_editor"=>"false"},:buzz_properties_tag_ids =>",123,122",:format=>:js
      }.to change(BuzzTag,:count).by(2)
    end


  end

  describe "Get insync_buzz_in_channel" do
    it "check channel variable" do
      get :insync_buzz_in_channel, :id=>@chan.id,:buzz_id=>@buzz.id,:format =>:js
      assigns[:channel].should eql @chan
    end
  end

  describe " limit user methods " do
    before{
      @user_ids = ["21", "3"]

      for i in 1..3 do
        create(:subscription,:channel=>@chan)
      end
      @users = @chan.subscribed_users
    }
    
    context "Get limit_user" do
      it "check flash notice" do
        get :limit_user, :buzz_id=>@buzz.id,:user_ids=>@user_ids,:format =>:js
        BuzzMember.stub(:limit_members).and_return("Buzz has been limited successfully.")
        flash[:notice].should eql "Buzz has been limited successfully."
      end
    end

    it "check flash when user_id is not passed and priority_response_users is not empty" do
      Buzz.any_instance.stub_chain(:priority_buzzs,:where,:map).and_return([21, 19, 4])
      get :limit_user, :buzz_id=>@buzz.id,:user_ids=>@user_ids,:format =>:js
      flash[:error].should eql "You cannot limit the buzz, Priority (or) Response Expected has been set for some users."
    end

    context "Get limit_buzz" do
      it "check subsribed users name" do
        get :limit_buzz,:channel_id => @chan.id,:buzz_id => @buzz.id,:format => :js
        assigns[:user_names].first.should eql @users.first
        assigns[:buzz].should eql @buzz
      end
    end

  end

  describe "channel_search " do
    it "channel_search" do
      get :channel_search ,:channel => "true"
    end
  end


  describe "user_has_priority_response_expected" do
    it "check the render " do
      get :user_has_priority_response_expected,:buzz_id => @buzz.id,:user_id => @user.id
      response.should render_template(:text => "")
    end
  end
  #  describe "Get edit" do
  #    before {
  #      @cug = create(:cug,:user=>@user)
  #      @sub = create(:subscription,:user =>@user,:channel=>@cug)
  #      @sub_a = create(:subscription,:user =>@user_a,:channel=>@cug)
  #      @sub_b =  create(:subscription,:user =>@user_b,:channel=>@cug)
  #      get :edit,:id=>@cug.id,:format=>:js
  #    }
  #
  #    it "fetchs current user subscription" do
  #      assigns[:channel].should eql @cug
  #      assigns[:subscription].should eql @sub
  #
  #    end
  #
  #    it "fetchs other users subcription " do
  #      assigns[:channel].should eql @cug
  #      assigns[:existing_members].first.should eql @sub_b.user
  #    end
  #  end
  #
  #  describe " Put Update" do
  #    before {
  #      @cug1 = create(:cug,:name=>"diffcug")
  #      @cug = create(:cug,:user=>@user,:name=>"mycug")
  #      @sub = create(:subscription,:user =>@user,:channel=>@cug1)
  #      @alias = create(:channel_alias,:name=>"aliasfi",:user =>@user,:channel=>@cug)
  #      create(:watch_channel,:user=>@user,:channel=>@cug)
  #    }
  #
  #    context "when change moderator request is given" do
  #      it {
  #        expect{
  #          put :update,:id=>@cug.id,:cug_fav_manage_mode=>'no',:aliase_name=>"",:subscription=>{:is_core=>"true"},:change_the_moderator=>@user_b.id,:members=>"#{@user_a.id},#{@user_b.id},#{@user.id}",:format=>:js
  #          @cug.reload
  #        }.to change(@cug,:user_id)
  #      }
  #    end
  #
  #    context "when switch core to peripheral request is given" do
  #      it {
  #        expect{
  #          put :update,:id=>@cug1.id,:unsubscribe=>true,:cug_fav_manage_mode=>'no',:aliase_name=>"",:subscription=>{:is_core=>"false"},:subscription_is_core_val=>"false",:change_the_moderator=>"",:members=>"#{@user_a.id},#{@user_b.id},#{@user.id}",:format=>:js
  #          @sub.reload
  #        }.to change(@sub,:is_core)
  #      }
  #    end
  #
  #    it "adding new alies name" do
  #      expect{
  #        put :update,:id=>@cug1.id,:unsubscribe=>true,:cug_fav_manage_mode=>'no',:aliase_name=>"aliascug",:subscription=>{:is_core=>"false"},:subscription_is_core_val=>"false",:change_the_moderator=>"",:members=>"#{@user_a.id},#{@user_b.id},#{@user.id}",:format=>:js
  #      }.to change(ChannelAlias,:count).by(1)
  #    end
  #
  #    it "delete alies name" do
  #      expect{
  #        put :update,:id=>@cug.id,:unsubscribe=>true,:cug_fav_manage_mode=>'no',:aliase_name=>" ",:subscription=>{:is_core=>"false"},:subscription_is_core_val=>"false",:change_the_moderator=>"",:members=>"#{@user_a.id},#{@user_b.id},#{@user.id}",:format=>:js
  #      }.to change(ChannelAlias,:count).by(-1)
  #    end
  #
  #
  #    it "updating alies name" do
  #      expect{
  #        put :update,:id=>@cug.id,:unsubscribe=>true,:cug_fav_manage_mode=>'no',:aliase_name=>"aliascug",:subscription=>{:is_core=>"false"},:subscription_is_core_val=>"false",:change_the_moderator=>"",:members=>"#{@user_a.id},#{@user_b.id},#{@user.id}",:format=>:js
  #        @alias.reload
  #      }.to change(@alias,:name)
  #    end
  #
  #    #    it "adding channel to favorite " do
  #    #      expect{
  #    #        put :update,:id=>@cug1.id,:unsubscribe=>true,:cug_fav_manage_mode=>'yes',:aliase_name=>"aliascug",:subscription=>{:is_core=>"false"},:subscription_is_core_val=>"false",:change_the_moderator=>"",:members=>"#{@user_a.id},#{@user_b.id},#{@user.id}",:format=>:js
  #    #      }.to change(WatchChannel,:count).by(1)
  #    #    end
  #    #
  #    #    it "deleteing channel to favorite " do
  #    #      expect{
  #    #        put :update,:id=>@cug.id,:unsubscribe=>true,:cug_fav_manage_mode=>'no',:aliase_name=>"aliascug",:subscription=>{:is_core=>"false"},:subscription_is_core_val=>"false",:change_the_moderator=>"",:members=>"#{@user_a.id},#{@user_b.id},#{@user.id}",:format=>:js
  #    #      }.to change(WatchChannel,:count).by(-1)
  #    #    end
  #    #
  #    #
  #    context "when cug is updated sucessfully" do
  #      it {put :update,:id=>@cug.id,:unsubscribe=>true,:cug_fav_manage_mode=>'no',:aliase_name=>"",:subscription=>{:is_core=>"true"},:change_the_moderator=>@user_b.id,:members=>"#{@user_a.id},#{@user_b.id},#{@user.id}",:format=>:js
  #        assigns[:message].should eql "CUG details successfully updated"
  #      }
  #    end
  #
  #
  #
  #  end
  #
  #  describe "Get search_members" do
  #    before{
  #      get :search_members,:q=>"c",:format=>:js
  #    }
  #
  #    it " the searched user" do
  #      assigns[:users].should have(1).items
  #    end
  #  end

end
