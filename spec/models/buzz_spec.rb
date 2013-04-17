require 'spec_helper'
=begin
def self.buzz_members
def get_buzz_member_names . both are same

def attachment_content_type
  +dont know how to test

  def self.channel_rezzout(channel_name, is_cug, buzz_msg, priority, user, apply_to, attachment = nil, buzz_id)
    +we cant enter to this line msg << "Please enter a valid buzz id"
=end


module Buzz_data
  def data
    @user = create(:user,:display_name=>"user")
    @ram = create(:user,:display_name=>"ram")

    @channel = create(:channel,:user=>@user)
    @cug = create(:cug, :user=>@ram)

    @buzz = create(:buzz,:channel=>@channel,:message =>"what r u doing")
    @buzz_a = create(:buzz,:channel=>@cug,:message =>"how can we test")
    @rezz = create(:buzz,:channel=>@channel,:ancestry =>@buzz.id)
  end
end

describe Buzz do
  include Buzz_data
  it { should belong_to(:channel) }
  it { should belong_to(:user) }
  it { should have_many(:buzz_insyncs).dependent(:destroy) }

  describe 'validation' do

  end

  describe ".channel_buzzout" do
    before(:all) do
      @user = create(:user, :first_name => 'ramesh', :last_name => 'lax', :display_name => "")
      @channel = create(:channel, :name=>"buzzezchannel", :user=> @user)
      @chan_alias = create(:channel_alias, :name=>"buzzalias", :user=>@user, :channel=>@channel)
    end

    context 'when buzzout to channel' do
      it {
        Buzz.channel_buzzout(@channel.name, "this is testing", @user).should  eql [["Buzzed out to Channel \"#{@channel.name}\" successfully"], @channel.id,true]
      }
    end

    context 'when invalid channel name is given' do
      it { 
        Buzz.channel_buzzout("@channel",  "this is testing",  @user).should eql [["$Channel doesn't exist or inactive"], 0, false]
      }
    end

    context 'when message is blank' do
      it {
        Buzz.channel_buzzout(@channel.name,  "", @user, "channel").should eql [["$Message can't be blank"], @channel.id,false]
      }
    end

    context 'when buzzout with unsubscribed user' do
      before { @bala = create(:user, :first_name=>'bala') }
      it {
        Buzz.channel_buzzout(@channel.name,  "this is testing simplecov", @bala, "channel").should eql [["$You must be subscribed to or owner of the Channel #{@channel.name}"], @channel.id,false]
      }
    end

    context 'when buzzout to alias channel' do
      it { 
        Buzz.channel_buzzout("buzzalias",  "this is testing simplecov", @user, "alias").should eql [["Buzzed out to Channel \"#{@channel.name}\" successfully"], @channel.id ,true]
      }
    end
  end



  #
  #    def data
  #    @user = create(:user,:display_name=>"user")
  #    @ram = create(:user,:display_name=>"ram")
  #
  #    @channel = create(:channel,:user=>@user)
  #    @cug = create(:cug, :user=>@ram)
  #
  #    @buzz = create(:buzz,:channel=>@channel,:message =>"what r u doing")
  #    @buzz_a = create(:buzz,:channel=>@cug,:message =>"how can we test")
  #    @rezz = create(:buzz,:channel=>@channel,:ancestry =>@buzz.id)
  #  end


  describe "#class method" do
    before { data
      @rezz_a = create(:buzz,:channel=>@channel,  :ancestry =>@buzz_a.id)
      @buzz_1 = create(:buzz,:user=>@user)
    }

    describe "#rezz" do
      context "success case"do
        it{@rezz.rezz?.should eql(true)}
      end

      context "fail case"do
        it{@buzz.rezz?.should eql(false )}
      end

    end

    describe "#buzzed_users" do
      it{@buzz.buzzed_users.first.should eql(@rezz.user_id)}
    end

    describe "#rezzed_users" do
      context "rezzed user id"do
        it{@buzz.rezzed_users.first.should eql @rezz.user_id}
      end
    end

  end

  describe "action view methods" do
    before(:all) do
      @user = create(:user)
      @ram = create(:user,:first_name => "ram")
      @channel = create(:channel,:user=>@user)
      @buzz = create(:buzz,:channel=>@channel,:user=>@user)
      @buzz1 = create(:buzz,:channel=>@channel,:user=>@ram,:message => "see man u can do it ")
      @priority_buzz = create(:priority_buzz,:buzz=>@buzz,:user=>@ram)
      @response_buzz = create(:response_expected_buzz,:buzz=>@buzz,:user=>@user)
      @awaiting_response_buzz = create(:response_expected_buzz,:buzz=>@buzz1,:user=>@user,:owner_id=>@ram.id)

    end

    context "#is_response_expected" do
      it{
        @buzz.is_response_expected(@user.id).should eql @response_buzz
      }
    end

    context "#is_awaiting_response" do
      it{
        @buzz1.is_awaiting_response(@ram.id).first.should eql @awaiting_response_buzz
      }
    end

    context "#is_priority_buzz" do
      it{
        @buzz.is_priority_buzz(@ram.id).first.should eql @priority_buzz
      }
    end

  end

  describe "#is_user_insync?" do
    before(:all) do
      @user = create(:user)
      @ram = create(:user)
      @buzz = create(:buzz,:user=>@user)
      @buzz_in = create(:buzz_insync, :buzz=>@buzz, :user=>@ram)
    end
    it{
      @buzz.is_user_insync?(@user.id).should eql true
    }
  end

  describe ".channel_buzzout" do
    before{
      @user = create(:user)
      @ram = create(:user)
      @buzz = create(:buzz,:user=>@user)
      @channel = create(:channel,:user=>@user)
    }

    #      context "when channel is not passed" do
    #        Buzz.channel_buzzout("","This is buzz message",@user).should eql "CUG/Channel doesn't exist or inactive"
    #      end
    
    context "when user is admin to channel " do
      it{
        Buzz.channel_buzzout(@channel,"This is buzz message",@user).should eql ["Buzzed out to Channel \"#{@channel.name}\" successfully"]
      }
    end

    context "when user is not subscribed to channel " do
      it{
        Buzz.channel_buzzout(@channel,"This is buzz message",@ram).should eql ["You must be subscribed to or owner of the Channel \"#{@channel.name}\""]
      }
    end

  end

  describe "#getting_buzz_name" do
    before {
      @user = create(:user)
      @ram = create(:user)
      @buzz = create(:buzz,:user=>@user)
      @buzz_name = create(:buzz_name,:user=>@user,:buzz=>@buzz)
      @buzz_flag = create(:buzz_flag,:user=>@user,:buzz=>@buzz)
    }

    context "getting the name of the buzz" do
      it{@buzz.getting_buzz_name(@user).should eql @buzz_name}
    end

    context "#buzz_flag_checked" do
      it{@buzz.buzz_flag_checked(@buzz_flag.flag,@user).should eql @buzz_flag}
    end
  end

  describe "#get_buzz_limited_member_names" do
    before{
      @users = create_list(:user,3)
      @buzz = create(:buzz)
      @buzz_member =[]
      @users.each { |user| @buzz_member << create(:buzz_member,:user=>user,:buzz => @buzz)}
    }

    context "checking list of users" do
      it{

        @buzz.get_buzz_limited_member_names(@buzz.buzz_members).should eql (@users.map{|user| user.full_name}).join(" , ")
      }
    end

  end

  describe "#set_rezz_name" do
    before{
      @user = create(:user)
      @buzz = create(:buzz,:user=>@user)
      @buzz1 = create(:buzz)
      @rezz = create(:buzz,:ancestry =>@buzz.id)
      @rezz1 = create(:buzz,:ancestry =>@buzz1.id)
      @buzz_name = create(:buzz_name,:buzz=>@buzz,:user=>@user)

    }

    context"if buzz has buzz name" do
      it{
        expect{
          @rezz.set_rezz_name(@user)
        }.to change{BuzzName.count}
      }
    end

    context"if buzz has no buzz name" do
      it{
        expect{
          @rezz1.set_rezz_name(@user)
        }.not_to change{BuzzName.count}
      }
    end

  end

  describe "rezz methods" do
    before{
      @users = create_list(:user,3)
      @buzz = create(:buzz)
      @rezz = create(:buzz,:ancestry =>@buzz.id)
      @rezzs = []
      @buzz_member =[]
      @users.each { |user| @rezzs << create(:buzz,:user => user,:ancestry =>@buzz.id)}
      @users.each { |user| @buzz_member << create(:buzz_member,:user=>user,:buzz => @buzz)}
      
    }

    context "#rezz?" do

      it"when buzz is passed" do
        @buzz.rezz?.should eql false
      end

      it"when rezz is passed" do
        @rezz.rezz?.should eql true
      end
    end

    context "#rezzed_users" do
      it{
        @rezz.rezzed_users.first.should eql @users.last.id
      }
    end

    context "#buzzed_users" do
      it{
        @buzz.buzzed_users.first.should eql @users.last.id
      }
    end

    context "#save_rezz_members" do
      it{
        expect{
          @rezz.save_rezz_members(@buzz)
        }.to change{BuzzMember.count}.by 2
      }
      
    end
  end

  describe "rezz methods" do
    before(:all) do
      @user = create(:user)
      @ram = create(:user,:first_name => "Ram")
      @channel = create(:channel,:user=>@user)
      create_list(:buzz,4,overrides = {:user => @user,:channel => @channel})
      @buzzs = Buzz.where("channel_id = ?",@channel.id)
      @pri_buzz = create(:priority_buzz,:buzz => @buzzs.first,:user_id => @ram.id)
      @response_buzz = create(:response_expected_buzz,:buzz => @buzzs[2],:user_id => @ram.id,:owner_id => @user.id)
    end

    context ".check_filters" do

      it "when priority_filter is given" do
        pri_params = {"channel_id"=>@channel.id, :show_out_insync=>"", :show_in_insync=>"", :priority_filter => "", :commit =>"Filter"}
        Buzz.check_filters(pri_params,@buzzs,@ram.id).first.should eql @buzzs.first
      end

      it "when awaiting_for_response_filter is given" do
        pri_params = {"channel_id"=>@channel.id, :show_out_insync=>"", :show_in_insync=>"", :awaiting_for_response_filter => "", :awaiting_for_response_filter_user => ["#{@ram.id}"],:commit =>"Filter"}
        Buzz.check_filters(pri_params,@buzzs,@user.id).first.should eql @buzzs[2]
      end

      it "when response_expected_filter is given" do
        pri_params = {"channel_id"=>@channel.id, :show_out_insync=>"", :show_in_insync=>"", :response_expected_filter => "", :commit =>"Filter"}
        Buzz.check_filters(pri_params,@buzzs,@ram.id).first.should eql @buzzs[2]
      end


    end
  end


end