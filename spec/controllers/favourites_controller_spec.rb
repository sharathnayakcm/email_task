require 'spec_helper'

describe FavouritesController do
  login_user
  include ActionView::Helpers::DateHelper

  before {
    @user = subject.current_user
    @chan = create(:channel,:user=>@user)
    @chan1 = create(:channel)
   @fav = create(:watch_channel,:user=>@user,:channel=>@chan1)
  }

  describe "Get add_to_watch" do

    it"adding the favorite channel"do
      expect {
        get(:create,:channel_id=>@chan.id,:format=>:js)
      }.to change(WatchChannel,:count).by(1)
    end

    it "the success msg will be" do
      get(:create,:channel_id=>@chan.id,:format=>:js)
      flash[:notice].should eql "Channel #{@chan.name} has been added successfully to your favorite list"
    end

    it"deleting the favorite channel"do
      expect {
        get(:destroy,:id=>@fav.id,:format=>:js)
      }.to change(WatchChannel,:count).by(-1)
    end

    it "the success msg will be" do
       get(:destroy,:id=>@fav.id,:format=>:js)
      flash[:notice].should eql "Channel #{@chan1.name} has been removed from your favorite list"
    end

  end
  
end
