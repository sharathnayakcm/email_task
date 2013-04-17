require 'spec_helper'

describe Admin::UsersController do
  login_admin
  before(:all)do
    create(:setting)
  end
  def valid_attributes
    {
      "display_name"=>"annabond",
      "first_name"=>"anna",
      "last_name"=>"bond",
      "email"=>"anna@in.com",
      "is_admin"=>"0",
      "is_active"=>"1",
      "password"=>"password",
      "password_confirmation"=>"password"
    }
  end

  describe "Get index" do
    it"should return all users"do
#      users = User.all
      get(:index)
      assigns[:users].first.should be_instance_of(User)
    end
  end

  describe "Get new" do
    it"should return new user"do
      get(:new)
      assigns[:user].should be_a_new(User)
    end
  end

  describe "Get create" do
    it"should create new user"do
      expect {
        post :create, {:user => valid_attributes}
      }.to change(User, :count).by(1)
    end

    it "check the flash and redirect after create" do
      User.any_instance.stub(:save).and_return(true)
      post :create,{:user=>valid_attributes}
      flash[:notice].should include("invited successfully")
      response.should redirect_to admin_users_path
    end

    it "Fail case must render" do
      User.any_instance.stub(:save).and_return(false)
      post :create, {:user => {}}
      response.should render_template 'new'
    end

  end


  describe "Edit and update user" do
    it "edit the user" do
      user = create(:user)
      get(:edit,'id'=>user.to_param)
      assigns[:user].should eql(user)
    end


    it "update the user" do
      user = create(:user)
      put(:update,:id =>user.id,:user => valid_attributes  )
      assigns[:user].should_not be_nil
      response.should redirect_to admin_users_path
    end


    it "check update_attributes should be called with params" do
      user = create(:user)
      User.any_instance.should_receive(:update_attributes).with( valid_attributes)
      put(:update,:id =>user.id,:user => valid_attributes  )
    end

    it "with invalid params" do
      user = create(:user)
      User.any_instance.stub(:save).and_return(false)
      put(:update,:id =>user.id,:user => {}  )
      response.should render_template 'edit'
    end
  end

#  describe "edit and update user preference" do
#    it"edit the user preference"do
#      user = create(:user)
#      get(:edit_user_preference,:id=>user.id)
#      assigns[:user].should eql user
#    end
#
#  end

  describe "deactivate the use" do
    before {
      @user = create(:user)
      get(:deactivate,:id=>@user.id)
    }
    it{flash[:notice].should include("deactivated successfully")}

    it {@user.reload.is_active.should == false}

    it {response.should redirect_to admin_users_path}
      
  
  end

  describe "activate the use" do
    before{
      @user = create(:user)
      get(:activate,:id=>@user.id)
    }
    it{flash[:notice].should include("activated successfully")}

    it {@user.reload.is_active.should == true}

    it{response.should redirect_to admin_users_path}
  end


#describe "Get moderator" do
#  it "return the owner_channels" do
#    subject.current_user.stub(:owner_channels).and_return({"id"=>1, "name"=>"mychannel"},{"id"=>2, "name"=>"2channel"})
#    subject.current_user.stub(:owner_cugs).and_return({"id"=>1, "name"=>"mycug"},{"id"=>2, "name"=>"mycug2"})
#    get(:moderator)
#    assigns[:channel].should have(2).items
#    assigns[:cug].should have(2).items
#  end
#
#  it "it render layout" do
#    get(:moderator)
#    response.should render_template "layouts/dashboard"
#  end
#end
#
#describe "Get channel details" do
#  it "should render channel info"do
#    channel = create(:channel)
#    get(:channel_details,:id=>channel.id)
#    response.should render_template 'channel_info'
#  end
#end
#
#describe "Get update channel" do
#  it "this will update channel"do
#    channel = create(:channel,:name=>'george')
#    Channel.any_instance.should_receive(:update_attributes).with({"name"=>"Rhom"}).and_return(true)
#    get(:update_channel,:id=>channel.id,:channel=>{"name"=>"Rhom"},:format=>:js)
#    flash[:notice].should include("updated successfully")
#  end
#
#  it "this will raise error for  update channel"do
#    @channel = create(:channel)
#    Channel.any_instance.should_receive(:update_attributes).with({"name"=>"Rhom"}).and_return(false)
#    put(:update_channel,:id=>@channel.id,:channel=>{"name"=>"Rhom"},:format=>:js)
#    assigns[:flag].should eql false
#  end
#end
#
#describe "Get Close_channel" do
#  before{
#    @channel = create(:channel)
#  }
#  it "this will close theh channel"do
#    Channel.any_instance.should_receive(:update_attributes).with({:is_active=>false}).and_return(true)
#    get(:close_channel,:id=>@channel.id,:is_active=>false,:format=>:js)
#    flash[:notice].should include("closed successfully")
#  end
#
#  it "fail case" do
#    Channel.any_instance.stub(:update_attributes).and_return(false)
#    get(:close_channel,:id=>@channel.id,:format=>:js)
#    @channel.is_active.should be true
#
#  end
#end
#
#describe "Get aliases" do
#  it "checking the aliases variables" do
#    @chan = create(:channel)
#    @cug = create(:channel,:is_cug=>true)
#    subject.current_user.should_receive(:user_channel_aliases).with(false).and_return(@chan)
#    subject.current_user.should_receive(:user_channel_aliases).with(true).and_return(@cug)
#    get(:aliases)
#    assigns[:user_channel_aliases].should eql @chan
#    assigns[:user_cug_aliases].should eql @cug
#  end
#end
#
#describe "Get settings" do
#  it "check  render "do
#    put(:settings)
#    response.should render_template('layouts/dashboard')
#  end
#
#  it "save the settings" do
#    Setting.any_instance.should_receive(:update_attributes).with(any_args()).and_return(true)
#    get(:save_settings)
#    flash[:notice].should include("successfully saved")
#    response.should redirect_to settings_users_path
#  end
#
#end
#
#describe "" do
#  it ""do
#
#  end
#end

end
