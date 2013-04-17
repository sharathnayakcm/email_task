require 'spec_helper'
=begin
  + self.subscribe_me
    * for failing condition (according to the code, it will return success_status as true)

  + #set_last_viewed
    * can also test the 'last_viewed' value
=end
describe Subscription do

  it { should belong_to(:user) }
  it { should belong_to(:channel) }

  describe "#user_id" do
    it{should validate_presence_of(:user_id)}
    it{ should validate_numericality_of(:user_id) }

  end

  describe '#channel_id' do
    it { should validate_presence_of(:channel_id) }
    it { should validate_numericality_of(:channel_id) }
    it do
      create(:subscription)
      should validate_uniqueness_of(:channel_id).scoped_to(:user_id).
        with_message(/^You have already subscribed to this channel/)
    end

  end

end
