require 'spec_helper'

describe BuzzMember do

  it {should belong_to(:channel)}
  it {should belong_to(:user)}
  it {should belong_to(:buzz)}


  describe '.limit_members' do
    before(:all) do
      @ram = create(:user, :first_name =>'buzzram')
      @user = create(:user)
      @user1 = create(:user)
      @buzz_chan = create(:channel)
      create(:subscription,:user=>@ram,:channel=>@buzz_chan)
      create(:subscription,:user=>@user1,:channel=>@buzz_chan)
      create(:subscription,:user=>@user,:channel=>@buzz_chan)
      @buzz = create(:buzz,:channel=>@buzz_chan)
      @rezz = create(:buzz,:channel=>@buzz_chan,:ancestry =>@buzz.id)
    end

    context "success case" do
      before{@users = User.find(@user1.id,@user.id)}
      it{ BuzzMember.limit_members(@buzz, @users).should eql "Buzz has been limited successfully."}
    end

    context "when users are not passed" do
      it{ BuzzMember.limit_members(@buzz).should eql "Buzz can be viewed by every members now!!"}
    end

    #    context "when user are not passed" do
    #      it{ BuzzMember.limit_members(@buzz, @user).should eql "Buzz can be viewed by every members now!!"}
    #    end

  end
end
