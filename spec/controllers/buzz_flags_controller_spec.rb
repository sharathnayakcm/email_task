require 'spec_helper'

describe BuzzFlagsController do
  login_user
  before {
    @user = subject.current_user
    @chan = create(:channel,:user=>@user)
    @buzz_a = create(:buzz)
    @buzz = create(:buzz,:user=>@user,:channel=>@chan)
    @flag = create(:flag)

  }

  describe "Get Index" do
    context "getting all the flags" do
      it{
        get :index ,:buzz_id=>@buzz.id,:format=>:js
        assigns[:flags].first.should eql @flag
      }
    end

    #    context " when buzz flag is not created" do
    #      it {
    #        get :index ,:buzz_id=>@buzz_a.id,:format=>:js
    #        assigns[:flags].first.should be_instance_of(Flag)
    #      }
    #    end
  end

  describe "Get create" do
    context "buzz will be added" do
      it{
        expect {
          post :create,:buzz_id=>@buzz_a.id,:buzz_flag=>{"0"=>{"flag_id"=>"2", "buzz_id"=>"307", "expiry_date"=>"18-07-2012"},
            "1"=>{"buzz_id"=>"307", "expiry_date"=>""}, "2"=>{"flag_id"=>"4", "buzz_id"=>"307", "expiry_date"=>"20-07-2012"},
            "3"=>{"buzz_id"=>"307", "expiry_date"=>""}, "4"=>{"buzz_id"=>"307", "expiry_date"=>""}},:format=>:js
        }.to change(BuzzFlag,:count).by(2)
      }
    end
  end

#  describe "Get filter_by_flags" do
#
#    before{
#      create(:flag,:id=>3,:name=>"Green")
#    }
#    it{
#      get :filter_by_flags,:format=>:js
#      assigns[:flags].should eql Flag.all
#    }
#  end
#
#  describe "Get buzzes_by_flags" do
#    it {
#      get :buzzes_by_flags ,:channel_id=>@chan.id,:flag_ids=>"",:format=>:js
#      assigns[:buzzes].should have(1).items
#    }
#  end


end
