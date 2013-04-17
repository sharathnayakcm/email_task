class BuzzTask < ActiveRecord::Base
  belongs_to :buzz, :inverse_of => :buzz_tasks
  belongs_to :user

  default_scope where(:status => false)
  scope :completed_dozzes, where(:status => true)

  PRIORITY = {:Low => 'low', :Medium => 'medium', :High => 'high'}

  attr_accessor :expiry_date
  validates :name, :presence => true

  #After save of dozz mail will be sent to the user to their dozz email
  after_save :send_email

  def send_email
    UserMailer.buzz_dozz(self).deliver unless self.status_changed?
  end

  def expiry_date
    due_date.strftime("%d %b %Y")
  end

  # for accessing virtual attribute expiry date in json structure
  def as_json(options={})
    super(:methods => [:expiry_date])
  end
end