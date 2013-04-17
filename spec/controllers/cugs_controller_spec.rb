require 'spec_helper'

describe CugsController do
  login_user

  before {
    @user = subject.current_user
    @user_a = create(:user,:first_name=>"sahana")
    @user_b = create(:user,:first_name=>"chaithanya")
    @chan = create(:channel,:user=>@user)
    @tag1 = create(:tag,:name=>"tag1")
    @buzz = create(:buzz,:user=>@user,:channel=>@chan)
    @buzz_name = create(:buzz_name,:buzz=>@buzz,:user=>@user)
    @b_tag = create(:buzz_tag,:buzz=>@buzz2,:tag=>@tag1)
    
  }

  describe "Get index" do
    before{
      (subject.current_user).stub(:default_view).and_return([{:default_view=>@default_view.id}])
    }
    context" when buzz name exist" do
      it{
        get :index ,:format=>:js
        assigns[:default_view].should eql 
      }
    end

  end

  describe "Get edit" do
    before {
      @cug = create(:cug,:user=>@user)
      @sub = create(:subscription,:user =>@user,:channel=>@cug)
      @sub_a = create(:subscription,:user =>@user_a,:channel=>@cug)
      @sub_b =  create(:subscription,:user =>@user_b,:channel=>@cug)
      get :edit,:id=>@cug.id,:format=>:js
    }

    it "fetchs current user subscription" do
      assigns[:channel].should eql @cug
      assigns[:subscription].should eql @sub
    
    end

    it "fetchs other users subcription " do
      assigns[:channel].should eql @cug
      assigns[:existing_members].first.should eql @sub_b.user
    end
  end

  describe " Put Update" do
    before {
      @cug1 = create(:cug,:name=>"diffcug")
      @cug = create(:cug,:user=>@user,:name=>"mycug")
      @sub = create(:subscription,:user =>@user,:channel=>@cug1)
      @alias = create(:channel_alias,:name=>"aliasfi",:user =>@user,:channel=>@cug)
      create(:watch_channel,:user=>@user,:channel=>@cug)
    }

    context "when change moderator request is given" do
      it {
        expect{
          put :update,:id=>@cug.id,:cug_fav_manage_mode=>'no',:aliase_name=>"",:subscription=>{:is_core=>"true"},:change_the_moderator=>@user_b.id,:members=>"#{@user_a.id},#{@user_b.id},#{@user.id}",:format=>:js
          @cug.reload
        }.to change(@cug,:user_id)
      }
    end

    context "when switch core to peripheral request is given" do
      it {
        expect{
          put :update,:id=>@cug1.id,:unsubscribe=>true,:cug_fav_manage_mode=>'no',:aliase_name=>"",:subscription=>{:is_core=>"false"},:subscription_is_core_val=>"false",:change_the_moderator=>"",:members=>"#{@user_a.id},#{@user_b.id},#{@user.id}",:format=>:js
          @sub.reload
        }.to change(@sub,:is_core)
      }
    end

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

    context "when cug members are given" do
      it{
        expect{
          put :update,:id=>@cug.id,:subscription=>{:is_core=>"true"},:channel =>{ :moderator_id => ""},:members=>"#{@user_a.id},#{@user_b.id},#{@user.id}",:format=>:js
        }.to change{Subscription.count}
      }
    end

    context "when cug is updated sucessfully" do
      it {put :update,:id=>@cug.id,:unsubscribe=>true,:cug_fav_manage_mode=>'no',:aliase_name=>"",:subscription=>{:is_core=>"true"},:change_the_moderator=>@user_b.id,:members=>"#{@user_a.id},#{@user_b.id},#{@user.id}",:format=>:js
        assigns[:message].should eql "CUG details successfully updated"
      }
    end

  end

  describe "Get search_members" do
    before{
      get :search_members,:q=>"c",:format=>:js
    }

    it " the searched user" do
      assigns[:users].should have(1).items
    end
  end

  describe "#get_cug_view" do
    context"when view has children" do
      it{
        get :get_cug_view ,:cug_view_type => "7",:format => :js
        assigns[:channels].first[:beehive_view_name].should eql "Priority"
      }
    end

    context"when view has ancestry" do
      it{
        get :get_cug_view ,:cug_view_type => "17",:format => :js
        assigns[:channels].first[:beehive_view_name].should eql "Priority"
      }
    end

    context"when view has no children and ancestry" do
      it{
        get :get_cug_view ,:cug_view_type => "9",:format => :js
        assigns[:channels].first[:beehive_view_name].should eql "Favorite"
      }
    end

  end

  describe "#show" do
    it{
      get(:show,:id=>@chan.id,:format=>:js)
      assigns[:channel].should eql @chan
    }
  end

  describe "#cugs_names_with_aliases" do
    it{
      get(:cugs_names_with_aliases)
    }
  end

  describe "#advance_search" do
    it{
      User.any_instance.stub_chain(:subscribed_channels_tag_list,:uniq!).and_return([{:tag_id=>92, :tag_name=>"tag1"}, {:tag_id=>115, :tag_name=>"tag2"}, {:tag_id=>72, :tag_name=>"tag3"}, {:tag_id=>114, :tag_name=>"tag2"}])
      User.any_instance.stub(:subscribed_channels_subscribed_user_list).and_return([{:user_id=>21, :user_name=>"sunil"}, {:user_id=>3, :user_name=>"Sharath"}, {:user_id=>6, :user_name=>"Smitha"}])
      get(:advance_search,:format =>:js)
      assigns[:subscribed_channels_tag_list].first[:tag_name].should eql "tag1"
      assigns[:subscribed_channels_subscribed_user_list].first[:user_name].should eql "sunil"
      assigns[:flags].should eql Flag.all
    }
  end


  describe "#buzz_properties" do
    before{
      @channel = create(:cug)
      @sub_a = create(:subscription,:user =>@user_a,:channel=>@channel)
      @sub_b =  create(:subscription,:user =>@user_b,:channel=>@channel)
      @tag1 = create(:tag,:channel=>@channel)
      @tag2 = create(:tag,:channel=>@channel)
    }

    it{
      get :buzz_properties,:channel_id=>@channel.id,:format=>:js
      assigns[:cug_tags].first.should eql [" tag1", @tag1.id]
      assigns[:user_names].first[:first_name].should eql "chaithanya"
    }

  end

end
