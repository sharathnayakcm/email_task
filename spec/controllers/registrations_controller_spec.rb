require 'spec_helper'

describe RegistrationsController do
  login_user
  
  before(:all)do
    create(:setting)
  end

  def valid_attributes
    {
      "display_name"=>"gayle",
      "first_name"=>"chris",
      "last_name"=>"gayle",
      "email"=>"gayle@in.com",
      "is_admin"=>"0",
      "is_active"=>"1",
      "password"=>"password",
      "password_confirmation"=>"password"
    }
  end

  describe "Get edit" do
    it "check current user"do
      get(:edit)
      assigns[:user].should eql subject.current_user
    end
  end


  describe "Edit and update user" do
  
    it "check update_attributes should be called with params" do
      @user = create(:user)
      User.stub(:find).and_return(@user)
      User.any_instance.should_receive(:update_attributes).with(valid_attributes).and_return(true)
      put(:update,:user => valid_attributes,:format=>:js)
      flash[:notice].should include("Profile has been saved successfully")
    end

#    it "with invalid params" do
#      @user = create(:user)
#      User.stub(:find).and_return(@user)
#      User.any_instance.should_receive(:update_attributes).with(valid_attributes).and_return(false)
#      put(:update,:user => valid_attributes,:format=>:js)
#      response.should render_template 'edit'
#    end

  end
end
