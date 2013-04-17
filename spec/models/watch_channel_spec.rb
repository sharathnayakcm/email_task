require 'spec_helper'

=begin
uniqueness od channel_id is not done
=end
describe WatchChannel do

  it { should belong_to(:user)}

  it { should belong_to(:channel)}

  describe "#user_id" do
    it{should validate_presence_of(:user_id)}
    it{ should validate_numericality_of(:user_id) }

  end

  describe '#channel_id' do
    it { should validate_presence_of(:channel_id) }
    it { should validate_numericality_of(:channel_id) }
    #    it do
    #      create(:watch_channel)
    #      should validate_uniqueness_of(:channel_id).scoped_to(:user_id).
    #        with_message(["/^is already added to your watch list$/"])
    #    end

  end
  
  before :all do
    @user = create(:user)
    @ram = create(:user)
    @watch_chan = create(:channel,:name=>"watchchan",:user=>@user)
    @channel = create(:channel,:user=>@user)
    @chan_alias = create(:channel_alias,:name=>"aliaswatch",:user=>@user,:channel=>@watch_chan)
    create(:watch_channel,:user=>@user,:channel=>@channel)
  end
end



