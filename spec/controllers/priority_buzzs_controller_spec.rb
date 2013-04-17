require 'spec_helper'

describe PriorityBuzzsController do
  login_user
  before {
    @user = subject.current_user
    @user_a = create(:user,:first_name=>"user_a")
    @user_b = create(:user,:first_name=>"user_b")
    @user_c = create(:user,:first_name=>"user_c")
    @user_d = create(:user,:first_name=>"user_d")


    @chan = create(:channel,:user=>@user)
    @chan_a = create(:channel,:user=>@user)

    create(:subscription,:user =>@user_c,:channel=>@chan)
    create(:subscription,:user =>@user_d,:channel=>@chan)

    @buzz_b =  create(:buzz,:user=>@user_a,:channel=>@chan)
    @buzz_a = create(:buzz)


  }


  describe "Get new" do
    context "Check user_name when buzz_members present" do
      before{
        create(:buzz_member,:user => @user_a,:buzz=>@buzz_b,:channel=>@chan)
        create(:buzz_member,:user => @user_b,:buzz=>@buzz_b,:channel=>@chan)
      }
      it{
        get :new ,:buzz_id =>@buzz_b.id,:format=>:js
        assigns[:user_names].should eql [@user_a,@user_b]
      }
    end

    context "Check user_name when buzz_members not present" do
      it{
        get :new ,:buzz_id =>@buzz_b.id,:format=>:js
        assigns[:user_names].first.should eql @user_c
      }
    end

  end

  describe "Post Create" do
    context " when sucessfully added " do
      it{
        expect{
          post :create,:buzz_id => @buzz_b.id, :buzz => {"priority_buzzs_attributes"=>{"0"=>{"user_id"=>"19", "_destroy"=>"0", "owner_id"=>"3"}, "1"=>{"user_id"=>"0", "_destroy"=>"false", "owner_id"=>"3"}}},:format=>:js
        }.to change{PriorityBuzz.count}.by(1)
      }
    end
  end

  context "check flash notice " do
    before {
      @priority = create(:priority_buzz,:user=>@user_a,:buzz=>@buzz_a)
    }
    it"when Priority buzz is blank" do
      PriorityBuzz.any_instance.stub(:blank?).and_return(true)
      post :create,:buzz_id => @buzz_b.id, :buzz => {"priority_buzzs_attributes"=>{"0"=>{"user_id"=>"19", "_destroy"=>"0", "owner_id"=>"3"}, "1"=>{"user_id"=>"0", "_destroy"=>"false", "owner_id"=>"3"}}},:format=>:js
      flash[:notice].should eql "Selected user(s) successfully added to the priority list for being InSync with this buzz"
    end

    it"when Priority buzz is not blank", :type => "priority" do
      PriorityBuzz.stub(:where).with({:buzz_id => @buzz_a.id}).and_return([@priority])
      @buzz_a.stub(:update_attributes).and_return(true)
      post :create,:buzz_id => @buzz_a.id, :buzz => {"priority_buzzs_attributes"=>{"0"=>{"user_id"=>"19", "_destroy"=>"0", "owner_id"=>"3"}, "1"=>{"user_id"=>"0", "_destroy"=>"false", "owner_id"=>"3"}}},:format=>:js
      flash[:notice].should eql "Successfully updated the priority list of user(s)."
    end

  end
  
  #Has to be checked not working
  
  #  context "when destroy is given" do
  #    before{
  #      create(:priority_buzz,:user=>@user_a,:buzz=>@buzz_b,:owner_id=>1)
  #    }
  #    it{
  #      expect{
  #        post:create,:buzz_id=>@buzz_b.id,:buzz=> {"priority_buzzs_attributes"=>{"0"=>{"user_id"=>@user_a.id, "_destroy"=>"1", "owner_id"=>"1"}, "1"=>{"user_id"=>"0", "_destroy"=>"false", "owner_id"=>"1"}}},:format=>:js
  #      }.to change{PriorityBuzz.count}.by(-1)
  #    }
  #  end

end
