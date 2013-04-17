class Channel < ActiveRecord::Base

  belongs_to  :user
  has_many    :channel_aliases
  has_many    :subscriptions
  has_many    :tags
  has_many    :buzzs, :inverse_of => :channel
  has_many    :watch_channels
  has_many    :buzz_insyncs
  has_many    :channel_associations
  has_many    :buzz_members
  has_many    :buzz_tasks, :through => :buzzs
  has_many    :subscribed_users, :through => :subscriptions, :source => :user
  has_many    :response_expected_buzzs, :through => :buzzs, :source => :response_expected_buzzs
  has_many    :priority_buzzs, :through => :buzzs, :source => :priority_buzzs
  has_many    :priority_buzz_users, :through => :priority_buzzs, :source =>:user
  has_many    :response_awaiting_users, :through => :response_expected_buzzs, :source =>:user

  accepts_nested_attributes_for :buzz_tasks, :allow_destroy => true
  accepts_nested_attributes_for :channel_aliases, :reject_if => :reject_alias, :allow_destroy => true
  accepts_nested_attributes_for :watch_channels,  :allow_destroy => true
  accepts_nested_attributes_for :buzzs,  :allow_destroy => true
  attr_accessor :moderator_id

  validates :name, :presence => true, :length => {:maximum => 25}, :uniqueness => { :case_sensitive => false }, :format => {:with => /\A([a-z0-9]+|)\z/i, :if => Proc.new{|c| c.is_active}, :message => "should be alphanumeric only"}

  BEEHIVE_KEYWORDS = ['my', 'all', 'here']

  before_save :validate_channel_name

  scope :user_channels, proc {|is_cug, user| where('channels.is_cug =? and users.id =? and channels.is_active =?', is_cug, user, true)}
  scope :search_user_channels, proc {|channel_name| where("(channels.name like '%#{channel_name}%' or channel_aliases.name like '%#{channel_name}%')")}
  scope :searched_channels, proc{|is_cug, search_word, user| where("(channels.is_cug =? and users.id =? and (channels.name like '%#{search_word}%' or channel_aliases.name like '%#{search_word}%') and channels.is_active =?)", is_cug, user, true)}

  #this is a validation method used for adding and editing alias name
  def reject_alias(attr)
    ali =  ChannelAlias.find_by_name_and_user_id(attr['name'],attr['user_id'])
    ali.blank? && attr['name'].blank?
  end

  #this is used as set and get for attr_accessor
  def moderator_id
    self.user_id
  end

  def moderator_id=(value)
    self.user_id = value if value.present?
  end

  #used for getting the moderator name
  def moderator_name(user)
    self.user_id == user.id ? 'You' : self.user.full_name
  end

  def is_subscribed?(user)
    self.subscriptions.map(&:user_id).include?(user.id)
  end

  #getting whether channel is CUG or Channel
  def channel_or_cug
    is_cug ? 'CUG' : 'Channel'
  end

  def is_core?(user)
    self.subscriptions.where('channel_id = ? and user_id = ?',self.id, user.id).first.try(:is_core)
  end

  #getting channel is core/peripheral respect to user
  def cug_status(current_user)
    is_core?(current_user) ? 'Core' : 'Peripheral'
  end

  #Finding active buzzers for a channel
  def active_buzzers
    self.buzzs.select('DISTINCT user_id').where('created_at > ?', APP_CONFIG['buzzer']['active_buzzers'].days.ago).count
  end

  #  Finding the core and Peripheral buzzers
  def type_buzzers(is_core)
    self.subscriptions.includes(:user).where(:is_core => is_core)
  end

  #getting buzzinsync status for a channel
  def insync_cug_stats
    self.subscriptions.includes({:user => :buzz_insyncs})
  end

  #getting buzzs for a cug
  def self.get_buzzs(cug, user, insync, limit, page)
    insync_id = BuzzInsync.where(:channel_id => cug,:user_id => user).select(:buzz_id).first.try(:buzz_id)
    if insync == 'false'     
      return Buzz.includes(:channel,:user).limited_buzzs(user, cug).out_of_sync(insync_id || 0).paginate(:page => page, :per_page => limit), (insync_id || 0)
    elsif insync == 'both'
      return Buzz.includes(:channel,:user).limited_buzzs(user, cug).paginate(:page => page, :per_page => limit), (insync_id || 0)
    else
      return Buzz.includes(:channel,:user).limited_buzzs(user, cug).in_sync(insync_id || Buzz.count).paginate(:page => page, :per_page => limit), (insync_id || 0)
    end
  end

  #getting buzzs for a channel
  def self.get_channel_buzzs(channel, limit, page)
    Buzz.includes(:channel,:user).where('channel_id = ?',channel).paginate(:page => page, :per_page => limit)
  end

  #saving channel members
  def save_cug_members(users)
    users.split(',').each do |user|
      self.subscriptions.create(:user_id => user, :is_core => true)
    end
  end

  #getting buzz rate for a channel
  def buzz_rate_count(buzz_rate)
    self.buzzs.where('created_at > ?', buzz_rate.to_i.hours.ago).count
  end

  #getting last insyc buzz id for a particular user
  def last_insynced_id(user)
    buzz_insyncs.select('buzz_id').find_by_user_id(user.id).try(:buzz_id) || 0
  end

  #unsubscribing user for a channel
  def unsubscribe_self(user)
    return "Sorry, You are not subscribed to #{self.channel_or_cug} #{self.name}" unless is_subscribed?(user)
    subscription = self.subscriptions.where(:user_id => user.id).first
    "You have been unscubscribed successfully from #{self.channel_or_cug} #{self.name}" if subscription.delete
  end

  #finding whether the logged in user and channel owner is same
  def is_admin?(user)
    user_id == user.id
  end

  #getting unsync buzz count
  def unsync_buzz_count(user)
    insync_id = self.last_insynced_id(user)
    Buzz.limited_buzzs(user.id, self.id).out_of_sync(insync_id).size || 0
  end

  #getting not viwed buzz count for channel
  def not_viewed_channel_buzzs_count(user, channel)
    subscription = Subscription.select("last_viewed").where(:channel_id => channel, :user_id => user).first
    if subscription
      subscription.last_viewed.blank? ? self.buzzs.where('user_id != ?', user).count : self.buzzs.where('user_id != ? and created_at > ?', user, subscription.last_viewed).count
    else
      #Buzz.where('channel_id = ? and created_at > ? and user_id != ?', self.id, APP_CONFIG['buzz']['new_buzzes'].hours.ago, user).count
      self.buzzs.count
    end
  end

  # used for advance search
  def self.advance_search_in_channel_buzzes(search_params, user, page)
    is_cug = (search_params[:beehive_search][:is_cug] == 'true')
    if search_params[:beehive_search][:current_cug_id].to_i > 0
      channels = Channel.includes(:subscriptions, :buzzs).where(:id => search_params[:beehive_search][:current_cug_id].to_i).all
    else
      channels = Channel.includes(:subscriptions, :buzzs).where("is_cug = ? and subscriptions.user_id = ? and channels.is_active = ?", is_cug, user.id, true)
    end
    beehive_search_buzz(channels, user, search_params, page)
  end

  #need to remove this once user model is refactored
  def get_channel_last_viewed(user)
    self.subscriptions.where(:user_id => user.id).map(&:last_viewed)
  end

  def get_response_awaiting_users(user)
    self.response_awaiting_users.where("response_expected_buzzs.owner_id = #{user}").uniq
  end
 
  def get_response_expected_users(user)
    self.response_expected_buzzs.where("response_expected_buzzs.user_id = #{user}").group('response_expected_buzzs.owner_id').uniq
  end

  private

  def validate_channel_name
    if BEEHIVE_KEYWORDS.include?(self.name.downcase)
      errors.add(:base, "'#{self.name}' is a beehive keyword. Please use different name for #{self.is_cug ? 'CUG' : 'Channel'} name")
      return false
    end
  end

  def self.beehive_search_buzz(channels, user, search_params, page = 1, per_page = 5)
    search_text = search_params[:beehive_search][:search_keyword]
    channel_list = []
    channels.each do |c|
      if search_params[:beehive_search][:search_type] == 'simple'
        conditions = "channels.id = #{c.id} and buzzs.message like '%#{search_text}%'"
      else
        tags = search_params[:beehive_search][:tags].nil? ? '' : user.subscribed_channels_tag_list_by_name(search_params[:beehive_search][:tags]).pluck(:tag_id).join(',')
        flags = search_params[:beehive_search][:flags].nil? || search_params[:beehive_search][:flags].include?('1') ? '' : search_params[:beehive_search][:flags].reject{|c| c.empty?}.join(',')
        buzzed_by = search_params[:beehive_search][:buzzed_by].nil? ? '' : search_params[:beehive_search][:buzzed_by].reject{|c| c.empty?}.join(',')

        conditions = "channels.id = #{c.id} and (channels.name like '%#{search_params[:beehive_search][:search_cug_name]}%' or channel_aliases.name like '%#{search_params[:beehive_search][:search_cug_name]}%') and buzzs.message like '%#{search_text}%'"
        (conditions += " and (tag_id in (#{tags}))") if tags.to_i > 0
        (conditions += " and (flag_id in (#{flags}) and buzz_flags.user_id = #{user.id} and (buzz_flags.expiry_date>= '#{Date.today}' or buzz_flags.expiry_date is Null))") if flags.to_i > 0
        conditions += " and buzzs.user_id in (#{buzzed_by})" if buzzed_by.to_i > 0
        if search_params[:beehive_search][:insync_type].nil? || (search_params[:beehive_search][:insync_type].include?('true') && search_params[:beehive_search][:insync_type].include?('false'))
          conditions += ""
        elsif search_params[:beehive_search][:insync_type].include?('true')
          conditions += " and (buzzs.id <= buzz_insyncs.buzz_id)"
        elsif search_params[:beehive_search][:insync_type] && search_params[:beehive_search][:insync_type].include?('false')
          conditions += " and (buzzs.id > buzz_insyncs.buzz_id and buzzs.user_id != #{user.id})"
        end
      end
      buzzs = Buzz.where(conditions).includes([{:channel => [:channel_aliases, {:buzz_insyncs => :user}]}, :buzz_tags, :buzz_flags]).paginate(:page => page, :per_page => per_page)
      channel_list << {:channel => c, :id => c.id, :name => (user.channel_aliases.where(:channel_id => c.id).select("name").first.try(:name) || c.name), :buzz_count => buzzs.size, :buzzs => buzzs} if buzzs.size > 0
    end
    channel_list.sort_by { |a| a[:name].downcase }
  end
end