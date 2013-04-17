class BuzzTag < ActiveRecord::Base
  belongs_to  :tag
  belongs_to  :buzz

  #used for saving the buzz tag
  def self.add_buzz_tag(buzz, tag)
    BuzzTag.find_or_create_by_buzz_id_and_tag_id(buzz.id, tag)
  end
end