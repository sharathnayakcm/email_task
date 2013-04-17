require 'spec_helper'

describe AdhocController do
  login_user
  before {
    @user = subject.current_user
    @user_a = create(:user,:first_name=>"user_a")

    @chan = create(:channel,:user=>@user)
    @adhoc = create(:channel,:name => "Adhoc", :is_cug => true,:user=>nil)

    create(:subscription,:user =>@user_a,:channel=>@chan)

    @buzz_b =  create(:buzz,:user=>@user_a,:channel=>@chan)
    @buzz_a = create_list(:buzz,3,:user=>@user_a,:channel=>@adhoc)

  }

  describe "Get inbox" do
    before {
      create_list(:buzz,3,:user => @user_a)
      get :inbox ,:format => :js
    }
    
    it "check the assigns buzz" do
      assigns[:buzzs].first.should eql @buzz_a.last
    end

    it "check unread buzz countg" do
      assigns[:unread_count].should eql 3
    end
  end


  describe "Get Sent" do
    before {
      @self_buzzs = create_list(:buzz,3,:user => @user,:channel=>@adhoc)
      get :sent_items ,:format => :js
    }

    it "check the assigns buzz" do
      assigns[:buzzs].first.should eql @self_buzzs.last
    end

  end
end
