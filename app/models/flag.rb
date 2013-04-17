class Flag < ActiveRecord::Base
  has_many :buzz_flags
  scope :custom_flags, where('id > 1')
end