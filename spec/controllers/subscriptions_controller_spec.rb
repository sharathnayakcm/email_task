require 'spec_helper'

describe SubscriptionsController do
  login_user
  before {
    @user = subject.current_user
    @cug = create(:cug,:user=>@user)
    @cug1 = create(:cug)
    @chan = create(:channel,:user=>@user)
    @sub = create(:subscription,:user =>@user,:channel=>@cug)
  }

  describe "subscribe to the channel" do

    
    it "check the flash" do
      get :create,:id => @cug1.id,:format=>:js
      flash[:notice].should include("You have been subscribed successfully ")
    end

    it{
      expect {
        post :create,:id => @cug1.id,:format=>:js
      }.to change(Subscription, :count).by(1)
    }

    context "when user is already subscribed" do
      it{
        get :create,:id => @cug.id,:format=>:js
        flash[:error].should eql ["Channel You have already subscribed to this channel."]
      }
    end

  end

end