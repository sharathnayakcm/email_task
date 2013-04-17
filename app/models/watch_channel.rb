class WatchChannel < ActiveRecord::Base
  belongs_to :user
  belongs_to :channel

  validates :user_id, :presence => true, :numericality => true
  validates :channel_id, :presence => true, :numericality => true, :uniqueness => {:scope => :user_id, :message => " is already added to your watch list"}
end