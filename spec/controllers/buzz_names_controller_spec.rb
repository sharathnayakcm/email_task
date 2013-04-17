require 'spec_helper'

describe BuzzNamesController do
  login_user

  before {
    @user = subject.current_user
    @chan = create(:channel,:user=>@user)
    @buzz_a = create(:buzz)
    @buzz = create(:buzz,:user=>@user,:channel=>@chan)
    @buzz_name = create(:buzz_name,:buzz=>@buzz,:user=>@user)
  }

  describe "Get New" do
    #    context" when buzz name exist" do
    #      it{
    #        get :new ,:buzz_id =>@buzz.id,:format=>:js
    #        assigns[:buzz_name].should eql @buzz_name
    #      }
    #    end

    it{
      get :new ,:buzz_id =>@buzz_a.id,:format=>:js
      assigns[:buzz_name].should be_a_new(BuzzName)
    }
    
  end
  #BuzzName.stub(:add_or_buzz_name).and_return([true, "Buzz Name is added successfully."])
  describe "Get create" do
    it{
      post :create ,:buzz_id =>@buzz.id,:buzz_name=>{:name => "name"},:format=>:js
      response.should render_template "buzz_names/update.js"
    }
    
  end

  #write case to check count


  describe "Get Edit" do
    it{
      get :edit,:id => @buzz.id,:format =>:js
      assigns[:buzz].should eql @buzz
      assigns[:buzz_name].should eql @buzz_name
    }
  end

  describe "Get update" do
    it{
      get :update ,:id=>@buzz.id,:buzz_id =>@buzz.id,:buzz_name=>{:name => "name"},:format=>:js
      response.should render_template "buzz_names/update.js"
    }

  end

  context "Get destroy" do
    it{expect{
        delete :destroy ,:id=>@buzz.id,:buzz_id =>@buzz.id,:format=>:js
      }.to change{BuzzName.count}
    }
  end
end
