require 'spec_helper'

describe BuzzTagsController do
  login_user
  before {
    @user = subject.current_user
    @chan = create(:channel,:user=>@user)
    @buzz_a = create(:buzz)
    @tag = create(:tag,:channel=>@chan)
    @buzz = create(:buzz,:user=>@user,:channel=>@chan)
    @buzz_tag = create(:buzz_tag,:buzz=>@buzz,:tag=>@tag)
  }

    describe "Get buzz_tag_list" do
#    context "assigns buzz check" do
#      it{
#        get :index ,:buzz_id =>@buzz.id,:channel_id =>@chan.id,:format=>:js
#        assigns[:buzz_tags].should eql @buzz
#        assigns[:buzz_tag].should be_a_new(BuzzTag)
#      }
#    end
    
    context "assigns tags check" do
      it {
        Tag.stub(:add_buzz_tag).and_return([[@tag.id],""])
        get :index ,:buzz_id =>@buzz.id,:channel_id =>@chan.id,:tag=>@tag.id,:format=>:js
        assigns[:cug_tags].first.should eql [@tag.name,@tag.id]
      }
    end

    context " when tag is empty check Flash notice" do
      it {
#        Tag.stub(:add_buzz_tag).and_return([[],"Please provide the tag"])
        
        get :index ,:buzz_id =>@buzz.id,:channel_id =>@chan.id,:tag=>@tag.id,:format=>:js
        response.should render_template 'buzz_tags/buzz_tag_list.js'
    
      }
    end
#    context "assigns buzz tags" do
#      it{
#        get :index ,:buzz_id =>@buzz.id,:channel_id =>@chan.id,:tag=>@tag.id,:format=>:js
#        assigns[:buzz_tags].first.should eql @buzz_tag
#      }
#    end
  end


  describe "Get Cug Tag" do
    context "assigns values " do
      it{
        BuzzTag.stub(:add_buzz_tag).and_return(@buzz_tag)
        get :create ,:buzz_id =>@buzz.id,:channel_id =>@chan.id,:buzz_tag=>@tag.id,:format=>:js
        assigns[:buzz_tag].should eql @buzz_tag
      }
    end
  end

  describe "Delete" do
#    context "check assigns" do
#      it {
#        get :destroy ,:buzz_id =>@buzz.id,:tag_id=>@tag.id,:id=>@buzz.id,:channel_id =>@chan.id,:format=>:js
#
#      }
#    end
    context "delete all " do
      it {
        expect{
          get :destroy ,:buzz_id =>@buzz.id,:tag_id=>@tag.id,:id=>@buzz.id,:channel_id =>@chan.id,:format=>:js
        }.to change{BuzzTag.count}
      }
    end
    
  end

#  context "get filter_by_tags" do
#    it{
#      get :filter_by_tags,:channel_id =>@chan.id,:format=>:js
#      assigns[:channel_tags].first.should eql @tag
#    }
#  end

  #  describe "filter_tags_by_buzzes" do
  #    context "check assigns tag_buzzes tag_buzzes" do
  #      it {
  #        Channel.any_instance.stub(:buzz_data).and_return([{:id=>1,:message=>"this is message",:name=>@user.full_name}])
  #       assigns[:buzzes].should eql true
  #      }
  #
  #    end
  #  end
end
