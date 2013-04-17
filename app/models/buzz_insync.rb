class BuzzInsync < ActiveRecord::Base
  belongs_to  :channel
  belongs_to  :user
  belongs_to  :buzz

  #insyncing with the unsync buzzs of a channel
  def self.insync(channel_id, buzz_id, user)
    buzz_insync = BuzzInsync.where(:channel_id => channel_id, :user_id => user.id).first
    buzz_insync ? buzz_insync.update_attributes(:buzz_id => buzz_id) : BuzzInsync.create(:channel_id => channel_id, :user_id => user.id, :buzz_id => buzz_id)
  end 
end