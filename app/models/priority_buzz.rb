class PriorityBuzz < ActiveRecord::Base
  belongs_to :user
  belongs_to :buzz
  
  scope :is_priority_buzz , proc {|buzz_id,user_id| where('buzz_id = ? and (owner_id = ? or user_id)',buzz_id,user_id)}

end
