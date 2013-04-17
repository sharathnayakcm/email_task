require 'spec_helper'
=begin
def self.add_buzz_tag .code not reviewed
def get_count .code has to be reviewed
=end

describe Tag do
  
  it { should belong_to(:channel) }
  it { should have_many(:buzz_tags) }
  it { should have_many(:buzzs).through(:buzz_tags) }

  describe "#name" do
    it{should validate_presence_of(:name)}
  end

  describe "#channel_id" do
    it{should validate_presence_of(:channel_id)}
    it{should validate_numericality_of(:channel_id)}
    it {
      create(:tag)
      should validate_uniqueness_of(:channel_id).scoped_to(:name).
        with_message(/^This tag is already exist for this channel$/)
    }
  end




  describe ".add_buzz_tag and get_count" do
    before {
      @user = create(:user)
      @ram = create(:user)
      @chan = create(:channel,:name=>"pankaj",:user=>@user)
      @tag = create(:tag,:name=>"tag1",:channel=>@chan)
      create(:buzz_tag,:tag=>@tag)
      create(:buzz_tag,:tag=>@tag)

    }
    context "success case msg " do
      it{Tag.add_buzz_tag(@chan,"tag2").second.should eql nil}
    end

    context "when already existing tag is added msg " do
      it{Tag.add_buzz_tag(@chan,"tag1").second.should eql "Tag name \"tag1\" already exist"}
    end

    context "when tag count is more then 25 then msg " do
      it{
        channel = mock_model('Channel')
        channel.stub_chain(:tags, :count).and_return(27)
        Tag.add_buzz_tag(channel, 'te').second.should eql  "Maximum limit of 25 tags per CUG has been reached.Hence new tag cannot be added."
      }
    end
  end

end
