require 'spec_helper'

describe UserPreference do

  describe '#user id' do
    it{ should validate_presence_of(:user_id) }
    it{ should validate_numericality_of(:user_id) }
    it{ UserPreference.create(:user_id=>2,:cug_view=>28,:channel_view=>23,:buzz_rate_1=>"12",:buzz_rate_2=>"24")
      should validate_uniqueness_of(:user_id)}
  end
  
end
