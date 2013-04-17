require 'spec_helper'

describe RezzsController do
  login_user
  before {
    @user = subject.current_user
  }

  #  describe "get view all" do
  #    it"get view all" do
  #      buzz = FactoryGirl.create(:buzz)
  #      sub_buzz = FactoryGirl.create(:buzz,:ancestry => buzz.id)
  #      get :view_all ,:hide =>"false",:format=>:js,:buzz_id=>sub_buzz.id
  #      assigns[:rezzs].should have(2).items
  #    end
  #  end

  describe "get destroy" do
    it"get view all" do
      buzz = FactoryGirl.create(:buzz)
      sub_buzz = FactoryGirl.create(:buzz,:ancestry => buzz.id)
      get :destroy ,:id =>buzz.id,:format=>:js,:buzz_id=>buzz.id
      assigns[:rezz].should eql buzz
    end
  end

  describe "get member" do
    before {
      @user = create(:user)
      @user_a = create(:user)
      @channel = create(:channel,:user=>@user)
      @subscription = create(:subscription, :channel => @channel, :user => @user_a)
      @buzz = create(:buzz,:user=>@user,:channel=>@channel)
      @rezz = create(:buzz,:ancestry =>@buzz.id)
    }

    it "get member with user_id" do
      get :members,:buzz_id=>@rezz.id,:user_id=>@user.id
      response.should render_template(:type=>"text")
    end

    it "get member without user_id" do
      get :members,:buzz_id=>@buzz.id
      response.should render_template(:type=>"text")
    end

  end


  describe "create the rezz" do
    before :all do
      @channel = create(:channel,:user=>@user)
      @buzz = create(:buzz,:channel=>@channel)
      @rezz = create(:buzz,:ancestry => @buzz.id)
    end
    
    it "check the assigns rezzs" do
      get :create,:buzz_id=>@buzz.id,:rezz=>{"message"=>"sdgfsd fgsdf gdfgd sfgsdf", "channel_id"=>@channel.id, "user_id"=>@user.id, "is_richtext_editor"=>"false"},:format=>:js
      assigns[:rezz].should be_instance_of(Buzz)
      flash[:notice].should include("successfully")
    end

    it{
      expect {
        get :create,:buzz_id=>@buzz.id,:rezz=>{"message"=>"sdgfsd fgsdf gdfgd sfgsdf", "channel_id"=>@channel.id, "user_id"=>@user.id, "is_richtext_editor"=>"false"},:format=>:js
      }.to change(Buzz, :count).by(1)
    }


  end




end