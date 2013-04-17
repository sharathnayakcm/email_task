require 'spec_helper'

describe TagsController do
  login_user
  before {
    @user = subject.current_user
    @chan = create(:channel,:user=>@user)
    @buzz_a = create(:buzz)
    @tag = create(:tag,:channel=>@chan)
    @buzz = create(:buzz,:user=>@user,:channel=>@chan)
    @buzz_tag = create(:buzz_tag,:buzz=>@buzz,:tag=>@tag)
  }

  describe "Get tag_list" do
    context "checking for tags" do

      it"should create new user"do
        expect {
          post :create,:tag => 'hai',:buzz_id => @buzz.id
        }.to change(Tag, :count).by(1)
      end

      it {
        Tag.stub(:add_buzz_tag).and_return([[@tag.id],""])
        get :create ,:buzz_id =>@buzz.id,:channel_id =>@chan.id,:tag=>@tag.id,:format=>:js
        assigns[:cug_tags].first.should eql [@tag.name,@tag.id]
      }

      it {
        Tag.stub(:add_buzz_tag).and_return([[@tag.id],""])
        get :create ,:buzz_id =>@buzz.id,:channel_id =>@chan.id,:tag=>@tag.id,:format=>:js
        assigns[:cug_tags].first.should eql [@tag.name,@tag.id]
      }

    end

    context " when tag is empty check Flash notice" do
      it {
        get :create ,:buzz_id =>@buzz.id,:channel_id =>@chan.id,:tag=>@tag.id,:format=>:js
        response.should render_template 'buzz_tags/buzz_tag_list.js'

      }
    end
  end

  describe "Get channel_tag" do
    before{
      Tag.stub(:add_buzz_tag).and_return(@tag.id,"")
    }
    it{
      get :channel_tag,:channel_id => @chan.id,:format =>:js
      assigns[:cug_tags].should eql [[" tag1", 1]]
    }
  end
end