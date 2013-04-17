class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :channel

  validates :user_id, :presence => true, :numericality => true
  validates :channel_id, :presence => true, :numericality => true, :uniqueness => {:scope => :user_id, :message => "You have already subscribed to this channel."}

  after_destroy {|s| WatchChannel.destroy_all "channel_id = #{s.channel_id} and user_id = #{s.user_id}"}  
end