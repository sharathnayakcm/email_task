class ResponseExpectedBuzz < ActiveRecord::Base
  belongs_to :user
  belongs_to :owner, :foreign_key => :owner_id, :class_name => "User"
  belongs_to :buzz

   scope :response_expected , proc {|buzz_id,user_id| where('buzz_id = ? and user_id = ?',buzz_id,user_id)}
end
