class ChannelAlias < ActiveRecord::Base
  belongs_to :channel
  belongs_to :user
  validates :name, :length => {:maximum => 25}, :uniqueness => { :scope => :user_id, :message => 'Alias for this channel already exists'}, :format => {:with => /\A([a-z0-9]+|)\z/i, :message => "should be alphanumeric only"}

end
