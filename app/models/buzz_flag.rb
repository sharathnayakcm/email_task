class BuzzFlag < ActiveRecord::Base
  belongs_to :buzz
  belongs_to :user
  belongs_to :flag
  scope :not_expired, lambda {|user| where('user_id = ? and (expiry_date>=? or expiry_date is Null)',user,Date.today)}
end