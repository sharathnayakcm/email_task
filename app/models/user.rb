require 'csv'
class User < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :encryptable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
    :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :id, :display_name, :first_name, :last_name, :email, :password, :password_confirmation, :remember_me, :is_admin, :authentication_token, :default_view, :user_preference_attributes, :is_active, :dozz_email,:dormant_days,:cug_view
  attr_accessor :default_view, :status_delivery

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :display_name, :uniqueness => true
  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates :email, :presence => true, :format => {:with => email_regex}
  validates :dozz_email, :presence => true
  validates :dozz_email, :format => {:with => email_regex}, :allow_blank => true
  validates :dormant_days, :presence => true,:numericality => { :only_integer => true ,:message=>"days should be numnber"}

  before_save :password_required?, :ensure_authentication_token
  after_create  :set_default_preference

  has_many    :channels
  has_one     :user_preference
  has_many    :subscriptions
  has_many    :channel_aliases
  has_many    :buzzs
  has_many    :watch_channels
  has_many    :favourite_cugs, :through => :watch_channels, :source => :channel, :conditions => "channels.is_active = true and channels.is_cug = true"
  has_many    :favourite_channels, :through => :watch_channels, :source => :channel, :conditions => "channels.is_active = true and channels.is_cug = false"
  has_many    :buzz_insyncs
  has_many    :buzz_tasks
  has_many    :buzz_names
  has_many    :response_expected_buzzs
  has_many    :priority_buzzs
  has_many    :user_priority_buzzs, :through => :priority_buzzs, :source =>:buzz

  accepts_nested_attributes_for :user_preference

  EMAIL_REGEX = /\b[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}\z/

  default_scope order(:first_name)

  before_validation do
    self.email = self.dozz_email = User.append_domain(self.email)
  end

  #getting user's full name
  def full_name
    display_name.blank? ? "#{first_name} #{last_name}".titleize : display_name.titleize
  end

  #getting whether user is admin or not
  def admin_status
    is_admin? ? "Yes" : "No"
  end

  #user's account status
  def user_account_status
    confirmed_at.blank? ? "Not Verified" : (is_active? ? "Verified" : "Deactivated")
  end

  #deactivate user
  def deactivate
    self.is_active = false
    self.status_delivery = 'deactivation'
    save
  end

  #activate user
  def activate
    self.is_active = true
    self.status_delivery = 'activation'
    save
  end

  #getting unsync buzzs count for cugs
  def get_cugs_unsync_count(cugs,show_insyn)
    channel_list = []
    cugs.each do |c|
      buzz_count = c.unsync_buzz_count(self)
      channel_list << {:id => c.id, :name => (self.channel_aliases.where(:channel_id => c.id).select("name").first.try(:name) || c.name), :buzz_count => buzz_count , :is_cug => c.is_cug, :created_by => c.user_id}
    end
    (show_insyn.blank? || show_insyn == "false") ? channel_list.delete_if { |a| a[:buzz_count] == 0 }.sort_by { |a| a[:buzz_count] }.reverse : channel_list.sort_by { |a| a[:name].downcase }
  end

  def get_channels_unsync_count(channels)
    channel_list = []
    channels.each do |c|
      buzz_count = c.not_viewed_channel_buzzs_count(self.id, c.id)
      channel_list << {:id => c.id, :name => (self.channel_aliases.where(:channel_id => c.id).select("name").first.try(:name) || c.name), :buzz_count => buzz_count , :is_cug => c.is_cug, :created_by => c.user_id}
    end
    channel_list
  end

  ############################################# views scope methods ##########################################################

  ################################################ view scope for cugs #######################################################
  #getting core cugs
  def core_cugs(cug_name = '')
    return Channel.includes(:channel_aliases, :subscriptions => :user).user_channels(true, self.id).where("is_core =?", true).search_user_channels(cug_name).order("channels.name")
  end

  #getting peripheral cugs
  def peripheral_cugs(cug_name = '')
    return Channel.includes(:channel_aliases, :subscriptions => :user).user_channels(true, self.id).where("is_core = ?", false).search_user_channels(cug_name).order("channels.name")
  end

  #getting fav cugs
  def fav_cugs(cug_name = '')
    Channel.includes(:channel_aliases).where("channels.id in (?)",self.favourite_cugs.map(&:id)).search_user_channels(cug_name)
  end

  # getting user's created cugs
  def owner_cugs(cug_name = '')
    Channel.includes(:channel_aliases, :user).user_channels(true, self.id).search_user_channels(cug_name)
  end

  # I think we are not using this function anymore
  def today_cugs(cug_name = '')
    Channel.includes({:subscriptions => :user}, :buzzs, :channel_aliases).user_channels(true, self.id).where("DATE(buzzs.created_at) = Date(?) and buzzs.user_id != ?", Time.now, self.id).search_user_channels(cug_name)
  end

  def today_cugs_buzzed_me(cug_name = '')
    Channel.includes({:subscriptions => :user}, :buzzs, :channel_aliases).user_channels(true, self.id).where("DATE(buzzs.created_at) = Date(?) and buzzs.user_id = ?", Time.now, self.id).search_user_channels(cug_name)
  end

  def priority_cugs(cug_name = '')
    @ids =[]
    channels = Channel.includes({:subscriptions => :user}, :channel_aliases, :priority_buzzs).user_channels(true, self.id).where("(priority_buzzs.user_id =? or priority_buzzs.owner_id = ?) and insync =?", self.id, self.id, false).search_user_channels(cug_name)
    @ids.push(channels.map(&:id))
    return channels
  end

  def responce_expected_cugs(cug_name = '')
    channels = Channel.includes({:subscriptions => :user}, :channel_aliases, :response_expected_buzzs).user_channels(true, self.id).where("response_expected_buzzs.user_id" => self.id).search_user_channels(cug_name)
    @ids.push(channels.map(&:id))
    return channels
  end

  def awaiting_responses_cugs(cug_name = '')
    channels = Channel.includes({:subscriptions => :user}, :channel_aliases, :response_expected_buzzs).user_channels(true, self.id).where("response_expected_buzzs.owner_id" => self.id).search_user_channels(cug_name)
    @ids.push(channels.map(&:id))
    return channels
  end

  def dormant_cugs(cug_name = '')
    ids = Channel.includes(:buzzs).select("id").where("buzzs.user_id != #{self.id} and DATE(buzzs.created_at) between '#{self.dormant_days.days.ago}' and '#{Time.now}'").map(&:id)
    cug_ids =  ids.blank? ? 0 : ids
    channels = Channel.includes({:subscriptions => :user}, :channel_aliases).user_channels(true, self.id).where("channels.id not in (?)", cug_ids).search_user_channels(cug_name)
    @ids.push(channels.map(&:id))
    return channels
  end

  def dozz_cugs(cug_name = '')
    channels = Channel.includes({:subscriptions => :user}, {:buzzs => :buzz_tasks}, :channel_aliases).user_channels(true, self.id).where("buzz_tasks.user_id = ? and buzz_tasks.status =?",self.id, false).search_user_channels(cug_name)
    @ids.push(channels.map(&:id))
    return channels
  end

  def normal_cugs(cug_name = '')
    Channel.includes({:subscriptions => :user}, :channel_aliases).user_channels(true, self.id).where("channels.id not in (?)", @ids.flatten.empty? ? 0 : @ids.flatten).search_user_channels(cug_name)
  end

  #used for updating the cugs in left pane
  def updating_responce_expected_cugs
    Channel.includes({:subscriptions => :user}, :buzzs, :response_expected_buzzs).user_channels(true, self.id).where("response_expected_buzzs.user_id" => self.id)
  end

  def updating_priority_cugs
    Channel.includes({:subscriptions => :user}, :buzzs, :priority_buzzs).user_channels(true, self.id).where("(priority_buzzs.user_id =? or priority_buzzs.owner_id = ?) and insync =?", self.id, self.id, false)
  end

  def updating_awaiting_responses_cugs
    Channel.includes({:subscriptions => :user}, :buzzs, :response_expected_buzzs).user_channels(true, self.id).where("response_expected_buzzs.owner_id" => self.id)
  end

  def updating_dozz_cugs
    Channel.includes({:subscriptions => :user}, {:buzzs => :buzz_tasks}).user_channels(true, self.id).where("buzz_tasks.user_id = ? and buzz_tasks.status =?",self.id, false)
  end

  def updating_normal_cugs
    pc = Channel.includes(:priority_buzzs).where("(priority_buzzs.user_id =? or priority_buzzs.owner_id = ?) and insync =?", self.id, self.id, false).map(&:id)
    res_awat_cugs =  Channel.includes(:response_expected_buzzs).where("response_expected_buzzs.user_id =? or response_expected_buzzs.owner_id =?", self.id, self.id).map(&:id)
    dormant_cugs = Channel.includes({:subscriptions => :user}, :buzzs).user_channels(true, self.id).select("id").where("buzzs.user_id != #{self.id} and DATE(buzzs.created_at) between '#{self.dormant_days.days.ago}' and '#{Time.now}'").map(&:id)
    dormant_cugs_ids = Channel.includes({:subscriptions => :user}).user_channels(true, self.id).where("channels.id not in (?)", dormant_cugs.blank? ? 0 : dormant_cugs).map(&:id)
    dozz_ids = Channel.includes({:subscriptions => :user}, {:buzzs => :buzz_tasks}).user_channels(true, self.id).where("buzz_tasks.user_id = ? and buzz_tasks.status =?",self.id, false)
    ids = pc+res_awat_cugs+dormant_cugs_ids+dozz_ids
    ids =  ids.blank? ? 0 : ids
    Channel.includes({:subscriptions => :user}).user_channels(true, self.id).where("channels.id not in (?)", ids.flatten)
  end


  
  def red_flag(cug_name = '')
    Channel.includes({:subscriptions => :user}, {:buzzs => :buzz_flags}, :channel_aliases).user_channels(true, self.id).where("buzz_flags.user_id =? and buzz_flags.flag_id = ? and (buzz_flags.expiry_date>=? or buzz_flags.expiry_date is Null)",self.id, 2, Date.today).search_user_channels(cug_name)
  end

  def green_flag(cug_name = '')
    Channel.includes({:subscriptions => :user}, {:buzzs => :buzz_flags}, :channel_aliases).user_channels(true, self.id).where("buzz_flags.user_id =? and buzz_flags.flag_id = ? and (expiry_date>=? or expiry_date is Null)",self.id, 3, Date.today).search_user_channels(cug_name)
  end

  def blue_flag(cug_name = '')
    Channel.includes({:subscriptions => :user}, {:buzzs => :buzz_flags}, :channel_aliases).user_channels(true, self.id).where("buzz_flags.user_id =? and buzz_flags.flag_id = ? and (expiry_date>=? or expiry_date is Null)",self.id, 4, Date.today).search_user_channels(cug_name)
  end

  def orange_flag(cug_name = '')
    Channel.includes({:subscriptions => :user}, {:buzzs => :buzz_flags}, :channel_aliases).user_channels(true, self.id).where("buzz_flags.user_id =? and buzz_flags.flag_id = ? and (expiry_date>=? or expiry_date is Null)",self.id, 5, Date.today).search_user_channels(cug_name)
  end

  def yellow_flag(cug_name = '')
    Channel.includes({:subscriptions => :user}, {:buzzs => :buzz_flags}, :channel_aliases).user_channels(true, self.id).where("buzz_flags.user_id =? and buzz_flags.flag_id = ? and (expiry_date>=? or expiry_date is Null)",self.id, 6, Date.today).search_user_channels(cug_name)
  end
  

  ################################################ view scope for channels #######################################################
  #fav channels
  def fav_channels(channel_name = '')
    Channel.includes(:channel_aliases).where("channels.id in (?)",self.favourite_channels.map(&:id)).search_user_channels(channel_name)
  end

  # subscribed channels
  def my_channels(channel_name = '')
    Channel.includes(:channel_aliases, {:subscriptions => :user}).user_channels(false, self.id).search_user_channels(channel_name).order("channels.name")
  end

  # new channels
  def new_channels(channel_name = '')
    Channel.includes(:channel_aliases, {:subscriptions => :user}).where("is_cug = ? and channels.created_at > ? and channels.is_active = ? and users.id != ?", false, Date.today - APP_CONFIG['channel']['new_channels'].to_i.days, true, self.id).search_user_channels(channel_name).order("channels.name")
  end

  # other channels
  def other_channels(channel_name = '')
    subscribed_channels = Channel.select("id").includes(:channel_aliases, {:subscriptions => :user}).user_channels(false, self.id)
    subscribed_channels_ids = subscribed_channels.blank? ? 0 : subscribed_channels.map(&:id)
    Channel.includes(:channel_aliases, {:subscriptions => :user}).where("is_cug = ? and channels.is_active = ? and channels.id NOT IN (?) and channels.created_at < ?", false, true, subscribed_channels_ids, Date.today - APP_CONFIG['channel']['new_channels'].to_i.days).search_user_channels(channel_name).order("channels.name")
    #raise ch.inspect
  end

  #getting today channels
  def today_channels_buzzed(channel_name = '')
    Channel.includes({:subscriptions => :user}, :buzzs, :channel_aliases).user_channels(false, self.id).where("DATE(buzzs.created_at) = Date(?) and buzzs.user_id != ?",Time.now, self.id).search_user_channels(channel_name).order('channels.name')
  end

  def today_channels_buzzed_me(cug_name = '')
    Channel.includes({:subscriptions => :user}, :buzzs, :channel_aliases).user_channels(false, self.id).where("DATE(buzzs.created_at) = Date(?) and buzzs.user_id = ?", Time.now, self.id).search_user_channels(cug_name)
  end

  #getting buzz insync id for a chanNonel of a particular user
  def get_buzz_insyncs(channel)
    self.buzz_insyncs.where("channel_id = ?", channel).order("created_at DESC").first
  end

  # return user's channel/CUG aliases
  def user_channel_aliases(is_cug)
    self.channel_aliases.includes(:channel).where('channels.is_cug = ?', is_cug)
  end

  # Generating a random password
  def new_random_password
    self.password= Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{self.first_name}--")[0,6]
    self.password_confirmation = self.password
  end

  def subscribed_channels_tag_list
    buzz_ids = subscribed_cug_list.map{|s| s.buzzs.map{|b| b.id}}
    BuzzTag.where("buzz_id in (?)", buzz_ids.flatten!).map{|bt| {:tag_id => bt.tag_id, :tag_name => bt.tag.name}}.sort_by { |a| a[:tag_name].downcase }
  end

  def subscribed_channels_tag_list_by_name(tag_names)
    buzz_ids = subscribed_cug_list.map{|s| s.buzzs.map{|b| b.id}}
    BuzzTag.joins(:tag).where("buzz_id in (?) and name in (?)", buzz_ids.flatten!, tag_names)
  end

  def subscribed_channels_subscribed_user_list
    subscribed_users = Subscription.where("channel_id in (?)", subscribed_cug_list.map{|s| s.id})
    subscribers_list = subscribed_users.map{|s| ({:user_id => s.user_id, :user_name => s.user.full_name}) unless s.user.nil? }.sort_by { |a| a[:user_name].downcase }
    subscribers_list.compact.uniq!
  end

  # count the buzzes in channel/ CUG
  def channel_buzz_count(c)
    c.is_cug ? c.unsync_buzz_count(self) : c.not_viewed_channel_buzzs_count(self.id, c.id)
  end

  # Subscribed CUG's list
  def subscribed_cug_list
    Channel.includes(:subscriptions => :user).user_channels(true, self.id)
  end

  #creating users from csv file
  def self.upload_csv(uploaded_csv)
    err_msg = []
    csv_file = uploaded_csv.read
    begin
      CSV.parse(csv_file, :headers => :first_row, :return_headers => false) do |row|
        email = User.append_domain(row[2])
        if User.is_valid_email?(email)
          user = User.new(:first_name => row[0], :last_name => row[1], :email => email, :dozz_email => email,:display_name => "#{row[0]} #{row[1]}" )
          user.new_random_password
          err_msg << "#{user.errors.full_messages[0]} for #{row[2]}" if !user.save
        else
          err_msg << "Invalid email #{row[2]}"
        end
      end
      err_msg
    rescue CSV::MalformedCSVError
      "Malformed CSV! Please check syntax"
    end
  end

  protected
  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil? if (self.new_record? || (!self.password.nil? && !self.password.empty?))
  end

  # Hack - to validate user with status active
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    email = self.append_domain(conditions.delete(:email))
    where(conditions).where(["lower(email) = :value and is_active = true", { :value => email.strip.downcase }]).first
  end

  private
  # set user's default preference
  def set_default_preference
    UserPreference.create({:user_id => self.id, :cug_view => BeehiveView.default_cug_view.id, :channel_view => BeehiveView.default_channel_view.id})
  end

  # email validation
  def self.is_valid_email?(email)
    email =~ EMAIL_REGEX
  end

  # formate the email id if user passed the email without domain name
  def self.append_domain(email)
    self.is_valid_email?(email) ? email : "#{email}@#{Setting.domain_name}"
  end
end