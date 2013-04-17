require 'spec_helper'

describe BuzzName do


  it{should validate_presence_of(:name)}
  it{should ensure_length_of(:name).is_at_most(40)}
  it{ should allow_value('Channel12').for(:name) }

  before {
    @user = create(:user)
    @channel = create(:channel,:user=>@user)
    @buzz = create(:buzz,:channel=>@channel,:user=>@user)
    @rezz = create(:buzz,:channel=>@channel,:ancestry =>@buzz.id)
    @buzz_name = create(:buzz_name,:buzz=>@buzz,:user=>@user)
  }

  describe ".add_or_update_buzz_name" do

    context "success case with new buzz name" do
      it{BuzzName.add_or_update_buzz_name(@buzz,@user,"reward").second.should eql "Buzz Name has been added successfully."}
    end


    context "success case with existing buzz name" do
      it{BuzzName.add_or_update_buzz_name(@buzz,@user,@buzz_name.name).second.should eql "Buzz Name has been added successfully."}
    end

    context "fail case " do
      it{
        BuzzName.any_instance.stub(:valid?).and_return(false)
        BuzzName.add_or_update_buzz_name(@buzz,@user,@buzz_name.name).should eql false}
    end

  end

  describe ".delete_buzz_name" do
    context "when buzz name is there" do
      it{
        expect{
          BuzzName.delete_buzz_name(@buzz,@user)
        }.to change{BuzzName.count}
      }
    end

    context "when buzz name is not there" do

      it{
        @buzz_a = create(:buzz)
        expect{
          BuzzName.delete_buzz_name(@buzz_a,@user)
        }.not_to change{BuzzName.count}
      }
    end

  end
end
