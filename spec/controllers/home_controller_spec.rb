require 'spec_helper'

describe HomeController do
  login_user
  include ActionView::Helpers::DateHelper

  before {
    @user = subject.current_user
    @chan = create(:channel,:user=>@user)
    @chan1 = create(:channel)
    @buzz = create(:buzz,:user=>@user,:channel=>@chan,:message=>"this word must be searched")
    @buzz1 = create(:buzz,:channel=>@chan1,:message=>"we can search this word also ")
    create(:watch_channel,:user=>@user,:channel=>@chan1)
  }
  
  describe "Get buzzers" do
    before{
      @channel = create(:channel)
      create(:subscription,:user=>subject.current_user,:channel=>@channel)
      create(:buzz,:message=>"we can search this word also",:channel=>@channel,:user=>subject.current_user)
    }

    it "buzzers list" do
      Channel.should_receive(:find_by_id).with(@channel.id.to_s).and_return(@channel)
      @channel.stub(:buzzers_list).and_return([{"id"=>1, "name"=>"Some1", "subscribed"=>"31 May 2012", "insynced_buzz"=>nil, "insynced_at"=>nil}])
      get(:buzzers,:type =>'core',:id=>@channel.id,:format =>:js)
      assigns[:buzzers].first.values_at(:id, :name).should eql [1,"Some1"]
    end
  end


  describe "Get help" do
    it "renders help page" do
      get(:help)
      response.should render_template 'layouts/admin'
    end
  end

  describe "Post beehive_search" do

    it"search the buzz"do
      Channel.stub(:advance_search_in_channel_buzzes).and_return([{:channel=>{ "id" => 2, :name=> 'Channel2', :is_cug => false, :user_id => 1, :is_active => true, :created_at => '2012-02-15 07:18:28', :updated_at => '2012-02-16 13:31:09', :description => nil, :buzzs=>{ :id => 791, :message => 'this is putti buzz', :channel_id => 2, :user_id => 3, :priority => false, :created_at => '2012-09-05 12:02:04', :updated_at => '2012-09-05 12:02:04', :attachment => nil, :ancestry => nil}}}])
      post(:beehive_search,:search_type =>"simple")
      assigns[:search_data].should have(2).items
    end

  end

  describe "Get beehive_search_more" do
    before{
      @channel = create(:channel)
    }

    it "beehive_search_more" do
      Channel.stub(:advance_search_in_channel_buzzes).and_return("[{:channel=>#<Channel id: 2, name: 'Channel2', is_cug: false, user_id: 1, is_active: true, created_at: '2012-02-15 07:18:28', updated_at: '2012-02-16 13:31:09', description: nil>, :id=>2, :name=>'Channel2', :buzz_count=>1, :buzzs=>[#<Buzz id: 791, message: 'fdghd fhgdfgh dfgh fdhgfdgh fdhg fdgh ', channel_id: 2, user_id: 3, priority: false, created_at: '2012-09-05 12:02:04, updated_at: '2012-09-05 12:02:04, attachment: nil, ancestry: nil>]}]")
      get(:beehive_search_more,:channel_id => @channel.id)
      assigns[:search_data].should_not be_empty
    end
  end

end
