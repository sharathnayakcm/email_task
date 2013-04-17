class Tag < ActiveRecord::Base
  belongs_to :channel
  has_many :buzz_tags
  has_many :buzzs ,:through => :buzz_tags
  validates :name, :presence => true
  validates :channel_id, :presence => true, :numericality => true, :uniqueness => {:scope => :name, :message => "This tag is already exist for this channel"}

  # Add tags to buzz
  def self.add_buzz_tag(channel,tags)
    if Tag.where(:channel_id => channel.id, :name => tags).first
      msg = "Tag name \"#{tags}\" already exist"
    else
      unless channel.tags.count >= 25
        tags_id = Tag.create(:channel_id => channel.id, :name => tags).id
      else
        msg = "Maximum limit of 25 tags per CUG has been reached.Hence new tag cannot be added."
      end
    end
    return tags_id, msg
  end
end