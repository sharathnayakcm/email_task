require 'spec_helper'

describe BuzzTasksController do
  login_user
  before {
    @user = subject.current_user
    @chan = create(:channel,:user=>@user)
    @buzz_a = create(:buzz)
    @tag = create(:tag,:channel=>@chan)
    @buzz = create(:buzz,:user=>@user,:channel=>@chan)
    @buzz_task = create(:buzz_task,:buzz=>@buzz,:user=>@user)
  }

  describe "get_buzz_or_channel" do
#    context "when channel is given" do
#      it{
#        get :channel_buzz_task_update,:id=>@chan.id,:is_channel=>true,:format=>:js
#        assigns[:channel].should eql @chan
#        assigns[:buzz_tasks].first.should eql @buzz_task
#
#      }
#    end
#
#    context "when buzz is given" do
#      it{
#        get :buzz_task_update,:id=>@buzz.id,:format=>:js
#        assigns[:buzz].should eql @buzz
#        assigns[:buzz_tasks].first.should eql @buzz_task
#
#      }
#    end

    context "when dozz is updated" do
      it{
        get :update,:channel_id=>@chan.id,:buzz_id=>@buzz.id,:is_channel=>true,:buzz =>{"buzz_tasks_attributes"=>{"new_1354784493911"=>{"name"=>"dfvdsfdf", "due_date"=>"19-Dec-2012", "priority"=>"low", "_destroy"=>"false", "user_id"=>"3"}}},:format=>:js
        flash[:notice].should eql "Sucessfully saved"
        assigns[:success].should eql true
      }
    end


  end

  describe "Get destory" do
    it{
      get :destroy,:buzz_task_id =>@buzz_task.id,:buzz_id=>@buzz.id,:channel_id=>@chan.id,:format=>:js
      assigns[:message].should eql "Dozz successfully deleted "
      response.should render_template "buzz_tasks/update_buzz_task_list.js"
    }
    
  end

  describe "Get buzz_task_mark_as_complete" do
    it{
      get :buzz_task_mark_as_complete,:buzz_task_id =>@buzz_task.id,:buzz_id=>@buzz.id,:channel_id=>@chan.id,:format=>:js
      assigns[:message].should eql "Dozz successfully marked as completed"
      response.should render_template "buzz_tasks/update_buzz_task_list.js"
    }
  end

end
