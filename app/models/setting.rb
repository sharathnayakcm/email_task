class Setting < ActiveRecord::Base
  store :company_info, accessors: [:domain_name]

  def self.domain_name
    Setting.first.nil? ? "" : Setting.first.domain_name
  end
end