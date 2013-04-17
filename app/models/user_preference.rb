class UserPreference < ActiveRecord::Base
  belongs_to :user
  validates :user_id, :presence => true, :numericality => true, :uniqueness => true
end