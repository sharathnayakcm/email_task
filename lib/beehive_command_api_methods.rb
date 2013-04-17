module BeehiveCommandApiMethods

  ########################### previously the below methods are in channel model start ##################################
  def moderator
    self.user.full_name
  end

  def status
    is_active == true ? 'Open' : 'Closed'
  end

  def moderator?(user)
    self.user_id == user.id ? "You" : self.user.full_name
  end

  def self.add_channels(channels, user, is_cug)
    msg = []
    success_status = true
    channels_name = ""
    if channels.count > 0
      channels.each do |c|
        channel = new({:name => c, :user_id => user.id, :is_cug => is_cug})
        if !channel.save
          channel.errors.full_messages.each do |e|
            msg << "$#{e}" unless msg.include?(e)
            success_status = false
          end
        else
          subscription = Subscription.new(:channel_id => channel.id, :user_id => user.id, :is_core => true)
          subscription.save
          channels_name += channel.name + ", "
        end
      end
      msg << "#{is_cug ? 'CUG' : 'Channel'} #{channels_name[0, channels_name.length - 2]} added successfully" if channels_name.present?
    else
      msg << "$Please provide atleast one #{is_cug ? 'CUG' : 'Channel'} name."
      success_status = false
    end
    return msg, success_status
  end

  def self.remove_channel(apply_to,channel_name,is_cug,user)
    msg = []
    success_status = false
    if apply_to == 'alias'
      channel = Channel.includes(:channel_aliases).where("channel_aliases.name = ?", channel_name).first
    else
      channel = Channel.where("name = ? and is_cug = ?", channel_name, is_cug).first
    end
    if !channel.nil?
      if channel.is_admin?(user)
        channel.is_active = false
        if channel.save
          msg << "#{channel.channel_or_cug} #{channel.name} removed successfully."
          success_status = true
        else
          msg << "Problem in removing channel #{channel.channel_or_cug} #{channel.name}"
        end
      else
        msg << "Only Admin/ Owner of #{channel.channel_or_cug} #{channel.name} can remove a #{channel.channel_or_cug}"
      end
    else
      msg << "#{is_cug ? 'CUG' : 'Channel'} doesn't exist or is inactive."
    end
    return msg,success_status
  end


  def tag_list
    self.tags.map(&:name).join(", ")
  end

  def set_last_viewed(user)
    subscription = Subscription.where(:channel_id => self.id, :user_id => user.id)
    if subscription.count > 0
      subscription.first.set_last_viewed
    end
  end

  def change_cug_type(user,type)
    subscription = self.subscriptions.where("user_id = ?", user.id).first
    subscription.is_core = (type.downcase != "core")
    subscription.save
    "Your involvement in this CUG changed to #{subscription.status}"
  end

  def channel_members
    subscribers = self.subscriptions.collect{|u| u.user}
  end

  # this method is used for mobile API
  def buzz_data(buzzes, user, is_cug)
    buzzes_data = []
    buzzes.each do |b|
      is_insynced = true
      if is_cug
        buzz_insync = BuzzInsync.where(:channel_id => b.channel_id, :user_id => user.id).first
        insync_buzz_id = buzz_insync.nil? ? 0 : buzz_insync.buzz_id
        is_insynced = b.user_id != user.id ? (b.id <= insync_buzz_id) : true
      end
      buzzes_data << {:id => b.id,
        :message => b.message,
        :buzzed_by => b.user_id == user.id ? 'You' : b.full_name,
        :created_at => time_ago_in_words(b.created_at).to_s + ' ago',
        :name => b.channel.name,
        :channel_id => b.channel_id,
        :is_cug => b.channel.is_cug,
        :insynced => is_insynced,
        :priority => b.priority,
        :attachment_path => b.attachment.current_path,
        :attachment_type => (b.attachment.blank? ? "" : b.attachment.set_content_type),
        :attachment_url => b.attachment.url,
        :attachment_name => b.attachment_name(b.attachment.url),
        :rezz_count => b.root.subtree.count,
        :childless => b.is_childless?,
        :descendants => b.has_descendents_or_parent?,
        :rezz => b.ancestry ? true :false,
        :limit_user_ids => b.buzz_members.any? ? b.buzz_members.collect{|bm| bm.user_id} : [],
        :limit_user_names => b.get_buzz_member_names,
        :is_limited => b.buzz_members.any?,
        :limit_users => b.buzz_members.any? ? b.buzz_members.collect{|bm| [bm.user_id, bm.user.display_name]} : [],
        :buzzed_by_id => b.user_id,
        :parent_id => b.parent_id,
        :channel_owner => b.channel.moderator?(user),
        :root_id => b.root_id,
        :buzz_tags => b.tags,
        :flag_count => b.buzz_flags.not_expired(user.id).count,
        :flag => b.buzz_flags.not_expired(user.id).map{|f| {:name => f.flag.name,:expiry => f.expiry_date}},
        :buzz_name => b.buzz_names.where("user_id = ?", user.id).any? ? b.buzz_name(b.buzz_names.where("user_id = ?", user.id).first.name) : "",
        :buzz_tasks=> b.buzz_tasks.where(:user_id => user.id)
      }
    end
    buzzes_data
  end

  def buzzers_list(is_core = nil)
    buzzers_list = []
    buzzers = is_core.nil? ? self.subscriptions.includes(:user) : self.subscriptions.includes(:user).where(:is_core => is_core)
    buzzers.map{|s|
      buzzers_list << {
        :id => s.user.id,
        :name => s.user.full_name,
        :subscribed => s.created_at.strftime("%d %b %Y"),
        :insynced_buzz => (s.user.buzz_insyncs.where(:channel_id => self.id).first.buzz.message if !s.user.buzz_insyncs.where(:channel_id => self.id).first.nil?),
        :insynced_at => (s.user.buzz_insyncs.where(:channel_id => self.id).first.updated_at.strftime("at %d %b %Y %I:%M %p") if !s.user.buzz_insyncs.where(:channel_id => self.id).first.nil?)
      }
    }
    return buzzers_list.uniq
  end

  def add_alias(channel_alias, channel, user)
    msg = []
    success_status = true
    channelalias = ChannelAlias.new(:channel_id => channel.id, :user_id => user.id, :name => channel_alias)
    if channelalias.save
      msg << "Alias has been added successfully."
    else
      channelalias.errors.full_messages.each do |e|
        msg << "$#{e}" unless msg.include?(e)
        success_status = false
      end
    end
    return msg, success_status
  end

  def buzzes_list(user, criteria = nil, filter1 = nil, filter2 = nil)
    buzzes = []
    if criteria == 'Buzz_Rate_1' || criteria == 'Buzz_Rate_2'
      buzz_rate = criteria == 'Buzz_Rate_1' ? 1 : 2
      buzzes = buzz_rate_buzzes_list(user, buzz_rate)
    elsif criteria == 'Today'
      buzzes = Buzz.where("channel_id = ? and DATE(created_at) = Date(?)", self.id, Time.now)
      buzz_data(buzzes, user, is_cug)
    elsif  criteria == 'By_Date'
      buzzes = Buzz.where("channel_id = ? and DATE(created_at) BETWEEN Date(?) and Date(?)", self.id, filter1, filter2)
      buzz_data(buzzes, user, is_cug)
    else
      buzzes = Buzz.where("channel_id = ?", self.id)
      buzz_data(buzzes, user, is_cug)
    end
  end

  def buzz_rate_buzzes_list(user,buzz_rate)
    buzzes = []
    buzz_rate_hr_ago = 0
    if buzz_rate.to_i == 1
      buzz_rate_value = user.user_preference.buzz_rate_1
    else
      buzz_rate_value = user.user_preference.buzz_rate_2
    end
    buzz_rate_hr_ago = buzz_rate_value.to_i.hours.ago
    buzzes = Buzz.where("channel_id = ? and created_at > ?", self.id, buzz_rate_hr_ago)
    buzz_data(buzzes, user, is_cug)
  end

  def total_buzzes
    self.buzzs.count('id')
  end

  def buzzers
    subscribers.count
  end

  def today_buzzes_count
    self.buzzs.where("DATE(buzzs.created_at) = Date(?)", Time.now).count
  end

  def channel_buzzes_count(time)
    self.buzzs.where("created_at > ?",time).count
  end

  def insync_search
    insync_cug_stats
  end

  def self.all_channels_search(search_text, is_cug, user)
    channels = Channel.where("is_cug = ? and name like '%#{search_text}%' and is_active = ?", is_cug, true)
    user.channels_with_buzz_count(channels)
  end

  def self.buzz_channels_search(search_text, is_cug = false, is_alias = false, search_channel_name = '', user)
    if is_alias
      channels = search_in_channel_alias(search_text, search_channel_name, user)
    elsif search_channel_name == 'my'
      channels = search_in_channel_buzzes(search_text, is_cug, user)
    elsif search_channel_name == 'all' && !is_cug
      channels = search_in_channel_buzzes(search_text, false, user) + search_in_all_channel_buzzes(search_text)
    else
      channels = search_in_channel_name(search_text, search_channel_name, is_cug, user)
    end
    search_buzz_count(channels)
  end


  def self.buzz_channels_cugs_search(search_text, user)
    other_cug_search = []
    channels_cug_search = Channel.includes(:subscriptions, :buzzs).where("subscriptions.user_id = ? and message like '%#{search_text}%' and channels.is_active = ?", user.id, true)
    if user.is_admin
      other_cug_search = buzz_other_cugs_search(search_text, user)
    end
    channels = channels_cug_search + other_cug_search
    return search_buzz_count(channels)
  end

  def self.search_in_all_channel_buzzes(search_text)
    Channel.includes(:buzzs).where("buzzs.message like '%#{search_text}%' and channels.is_active = ? and is_cug = ?", true, false)
  end

  def self.search_in_channel_buzzes(search_text, is_cug, user)
    Channel.includes(:subscriptions, :buzzs).where("is_cug = ? and subscriptions.user_id = ? and buzzs.message like '%#{search_text}%' and channels.is_active = ? and buzzs.id not in(?)", is_cug, user.id, true, user.user_accessible_buzz_ids)
  end

  def self.search_in_channel_alias(search_text, search_alias_name, user)
    Channel.includes(:channel_aliases, :buzzs).where("channel_aliases.user_id = ? and channel_aliases.name = ? and buzzs.message like '%#{search_text}%' and channels.is_active = ? and buzzs.id not in(?)", user.id, search_alias_name, true, user.user_accessible_buzz_ids)
  end

  def self.search_in_channel_name(search_text, search_channel_name, is_cug, user)
    Channel.includes(:subscriptions, :buzzs).where("is_cug = ? and subscriptions.user_id = ? and channels.name = '#{search_channel_name}' and buzzs.message like '%#{search_text}%' and channels.is_active = ? and buzzs.id not in(?)", is_cug, user.id, true, user.user_accessible_buzz_ids)
  end

  def self.buzz_other_cugs_search(search_text, user)
    Channel.includes(:subscriptions, :buzzs).where("subscriptions.user_id = ? and buzzs.message like '%#{search_text}%' and is_cug = ? and channels.is_active = ? and buzzs.id not in(?)", user.id, true, true, user.user_accessible_buzz_ids)
  end
  ########################### previously the below methods are in channel model end ##################################


  ########################### previously the below methods are in user model start #####################################
  # Hack - to validate user with status active
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    email = self.append_domain(conditions.delete(:email))
    where(conditions).where(["lower(email) = :value and is_active = true", { :value => email.strip.downcase }]).first
  end
  
  def core_peripheral_cugs(type)
    channels = (type == 'Core'? core_subscribed_cug_list : peripheral_subscribed_cug_list)
    channels = channels.uniq.sort_by{|c| c[:name].downcase}
    buzz_count(channels)
  end

  #  def get_cugs(is_core)
  #    return Channel.includes(:subscriptions => :user).where("is_cug = ? and users.id = ? and channels.is_active = ? and is_core = ?", true, self.id, true, is_core).order(:name)
  #  end

  def core_subscribed_cug_list
    Channel.select("channels.id, channels.name, channels.is_cug, channels.user_id").includes(:subscriptions => :user).where("is_cug = ? and users.id = ? and channels.is_active = ? and subscriptions.is_core = ?", true, self.id, true, true).order("channels.name")
  end

  def peripheral_subscribed_cug_list
    Channel.select("channels.id, channels.name, channels.is_cug, channels.user_id").includes(:subscriptions => :user).where("is_cug = ? and users.id = ? and channels.is_active = ? and subscriptions.is_core = ?", true, self.id, true, false).order("channels.name")
  end


  def today_buzzes_api
    {:channels => today_buzzed_channels(false), :cugs => today_buzzed_channels(true)}
  end

  def today_buzzed_channels(is_cug)
    channels = Channel.includes({:subscriptions => :user}, :buzzs).where("users.id = ? and DATE(buzzs.created_at) = Date(?) and is_cug = ? and channels.is_active = ?", self.id, Time.now, is_cug, true).order('channels.name')
    buzz_count(channels.uniq)
  end

  def today_buzzes_count
    buzz_count = 0
    self.subscriptions.each{|s| buzz_count += s.channel.buzzs.where("DATE(buzzs.created_at) = Date(?)", Time.now).count}
    buzz_count
  end

  # list of channels buzzed with in a time period for API
  def calendar_buzzes_api(start_date, end_date)
    {:channels => calendar_buzzed_channels(false, start_date, end_date), :cugs => calendar_buzzed_channels(true, start_date, end_date)}
  end

  #used for mobile API
  def calendar_buzzed_channels(is_cug, start_date, end_date)
    subscribed_channel = Channel.includes({:subscriptions => :user}, :buzzs).where("users.id = ? and DATE(buzzs.created_at) BETWEEN Date(?) and Date(?) and is_cug = ? and channels.is_active = ?", self.id, start_date, end_date, is_cug, true).order('channels.name')
    calendar_buzz_count(subscribed_channel, start_date, end_date)
  end

  def user_accessible_buzz_ids
    bid = buzzs_i_am_not_member - buzzs_i_am_member
    bid = bid.any? ? bid.uniq : [0]
    bid
  end

  def buzzs_i_am_member
    BuzzMember.where("user_id =?",self.id).collect{|b| b.buzz_id}
  end

  def buzzs_i_am_not_member
    BuzzMember.where("user_id !=?",self.id).collect{|b| b.buzz_id}
  end

  # fav. channel list for API
  def watch_channels_buzzes_api
    channels = []
    watch_channels = self.watch_channels.includes(:channel, :user).where("channels.is_active = true")
    watch_channels.map{|w| channels << w.channel unless w.channel.nil?}
    buzz_count(channels)
  end

  def channels_with_buzz_count(channels)
    buzz_count(channels)
  end

  def buzz_count(channels, assoc = false)
    channel_list = []
    channels.each do |c|
      c = c.channel if assoc
      alise_name = ChannelAlias.select("name,id").where(:user_id => self.id, :channel_id => c.id).first
      alise_name = alise_name.blank? ? nil : alise_name.name
      # I have created a common function - channel_buzz_count(c) for counting out of sync buzzes below this code. Will use that function in future
      if c.is_cug
        last_insyced_id = c.last_insynced_id(self)
        unsync_buzzs =  c.channel_buzzes_after_insync(self,last_insyced_id).collect{|b| b.id}
        buzzes =  c.buzzes_after_insync_buzz_as_not_a_member(self,last_insyced_id) - c.buzzes_after_insync_buzz_as_a_member(self,last_insyced_id)
        buzz_count= (unsync_buzzs - buzzes).size
      elsif c.subscriptions.map(&:user_id).include?(self.id)
        last_viewed = c.get_channel_last_viewed(self)
        buzz_count = (last_viewed.blank? || last_viewed[0].nil?) ? Buzz.where("channel_id = ? and user_id != ?", c.id, self.id).count : Buzz.where("channel_id = ? and created_at > ? and user_id != ?", c.id, last_viewed, self.id).count
      else
        buzz_count = Buzz.where("channel_id = ? and created_at > ? and user_id != ?", c.id, APP_CONFIG['buzz']['new_buzzes'].hours.ago, self.id).count
      end
      channel_list << {:id => c.id, :name => alise_name || c.name, :buzz_count => buzz_count, :is_cug => c.is_cug, :created_by => c.user_id}
    end
    # Sorting channel list according to count of unread buzzes
    channel_list.sort{|a,b| [b[:buzz_count], a[:name].downcase]  <=> [a[:buzz_count], b[:name].downcase]}
  end

  # buzz hash data with extra properties
  def buzz_data(buzzes)
    buzzes_data = []
    buzzes.each do |b|
      is_insynced = true
      if b.channel.is_cug
        buzz_insync = BuzzInsync.where(:channel_id => b.channel_id, :user_id => self.id).first
        insync_buzz_id = buzz_insync.nil? ? 0 : buzz_insync.buzz_id
        is_insynced = b.user_id != self.id ? (b.id <= insync_buzz_id) : true
      end
      buzzes_data << {:id => b.id,
        :message => b.message,
        :buzzed_by => b.user_id == self.id ? 'You' : b.full_name,
        :created_at => time_ago_in_words(b.created_at).to_s + ' ago',
        :name => b.channel.name,
        :channel_id => b.channel_id,
        :is_cug => b.channel.is_cug,
        :insynced => is_insynced,
        :priority => b.priority,
        :attachment_path => b.attachment.current_path,
        :attachment_type => (b.attachment.blank? ? "" : b.attachment.set_content_type),
        :attachment_url => b.attachment.url,
        :attachment_name => b.attachment_name(b.attachment.url),
        :rezz_count => b.root.subtree.size,
        :childless => b.is_childless?,
        :descendants => b.has_descendents_or_parent?,
        :rezz => b.ancestry ? true :false,
        :limit_user_ids => b.buzz_members.any? ? b.buzz_members.collect{|bm| bm.user_id} : [],
        :limit_user_names => b.get_buzz_member_names,
        :is_limited => b.buzz_members.any?,
        :limit_users => b.buzz_members.any? ? b.buzz_members.collect{|bm| [bm.user_id, bm.user.full_name]} : [],
        :buzzed_by_id => b.user_id,
        :parent_id => b.parent_id,
        :root_id => b.root_id,
        :buzz_tags => b.tags,
        :flag_count => b.buzz_flags.not_expired(self.id).count,
        :flag => b.buzz_flags.not_expired(self.id).map{|f| {:name => f.flag.name,:expiry => f.expiry_date}},
        :buzz_name => b.buzz_names.where("user_id = ?", self.id).any? ? b.buzz_name(b.buzz_names.where("user_id = ?", self.id).first.name) : "",
        :buzz_tasks=> b.buzz_tasks.where(:user_id => self.id)
      }
    end
    buzzes_data
  end

  #used for mobile API
  def calendar_buzz_count(channels, start_date, end_date)
    channel_list = []
    channels.each do |c|
      channel_list << {:id => c.id,
        :name => c.name,
        :buzz_count => Buzz.where("channel_id = ? and DATE(created_at) BETWEEN Date(?) and Date(?)", c.id, start_date, end_date).count,
        :is_cug => c.is_cug}
    end
    channel_list
  end

  ########################### previously the below methods are in user model end #####################################

  ########################### previously the below methods are in buzz model start #####################################
    
  ################# Below methods are used for the mailman ####################################
  def self.channel_buzzout(channel_name, is_cug, buzz_msg, priority, user, apply_to, attachment = nil)
    msg = []
    success_status = false
    channel_id = 0
    if apply_to == 'alias'
      channel = Channel.joins(:channel_aliases).where("channel_aliases.name = ? and channels.is_active = ?", channel_name, true).first
    else
      channel = Channel.where("name = ? and is_cug = ? and is_active = ?", channel_name, is_cug, true).first
    end

    if channel.nil?
      msg << "$#{is_cug ? 'CUG' : 'Channel'} doesn't exist or inactive"
    else
      channel_id = channel.id
      if channel.is_admin?(user) || channel.is_subscribed?(user)
        buzz = Buzz.new(:message => buzz_msg, :channel_id => channel.id, :user_id => user.id, :priority => priority, :attachment => attachment)
        if buzz.save
          associated_channel_buzz_post(buzz)
          msg << "Buzzed out to #{channel.channel_or_cug} \"#{channel.name}\" successfully"
          success_status = true
        else
          buzz.errors.full_messages.each{|e| msg << "$#{e}" unless msg.include?(e)}
        end
      else
        msg << "$You must be subscribed to or owner of the #{channel.channel_or_cug} #{channel.name}"
      end
    end
    return msg, channel_id, success_status
  end

  def self.associated_channel_buzz_post(buzz)
    associated_channels = ChannelAssociation.where(:cug_id => buzz.channel_id)
    associated_channels.each do |acug|
      Buzz.create(:message => buzz.message, :channel_id => acug.channel_id, :user_id => buzz.user_id, :priority => buzz.priority, :attachment => buzz.attachment)
    end
  end

  def self.channel_rezzout(channel, buzz_msg, priority, user,attachment = nil, buzz_id)
    msg = []
    success_status = false
    if channel.is_admin?(user) || channel.is_subscribed?(user)
      parent_buzz = channel.buzzs.find(buzz_id)
      if parent_buzz
        buzz = parent_buzz.children.new(:message => buzz_msg, :channel_id => channel.id, :user_id => user.id, :priority => priority, :attachment => attachment)
        if buzz.save
          buzz.save_rezz_members(parent_buzz)
          msg << "Rezzed out to #{channel.channel_or_cug} #{channel.name} successfully"
          success_status = true
        else
          buzz.errors.full_messages.each{|e| msg << "#{e}" unless msg.include?(e)}
        end
      else
        msg << "Please enter a valid buzz id"
      end
    else
      msg << "You must be subscribed to or owner of the #{channel.channel_or_cug} #{channel.name}"
    end
    return msg, success_status
  end

  def save_rezz_members buzz
    buzz.buzz_members.each{|member| self.buzz_members.create({:channel_id => buzz.channel_id, :user_id => member.user_id})}
  end

  ################# Below methods are used for the mobile API ####################################

  #Getting buzz members name
  def get_buzz_member_names
    user_name = []
    self.buzz_members.order("users.first_name asc").each{|member| user_name << member.user.full_name}
    user_name.join(" , ")
  end

  def self.remove_buzz(buzz_id)
    msg = []
    buzz = Buzz.where(:id => buzz_id).first
    if buzz.nil?
      msg << buzz.errors.full_messages
    else
      buzz.children.destroy_all
      buzz.destroy
      msg << 'This buzz has been deleted successfully.'
    end
    msg
  end

  def buzzed_user_fullname
    self.user.full_name
  end

  def generate_rezz_command(message)
    channel = self.channel.is_cug ? "@#{self.channel.name}" : "##{self.channel.name}"
    command = "r#{channel} #{self.id} #{message}"
    return command
  end

  def has_descendents_or_parent?
    self.root.descendants.any? or !self.parent.nil?
  end


  #getting the full name of the buzzed user
  def self.buzz_members buzz_id
    self.find(buzz_id).get_buzz_member_names
  end

  def buzz_flag_expiry_date(flag, user, format="%d-%m-%Y")
    expiry_date = buzz_flags.where("flag_id=? and user_id=? and (expiry_date >=? or expiry_date is Null)",flag.id,user.id,Date.today).first.try(:expiry_date) || ""
    return expiry_date.to_date.strftime(format) if expiry_date.present?
  end


  ########################### previously the below methods are in buzz model end #####################################


  ########################### previously the below methods are in flag model start #####################################
  #This method is used for the mobile API
  def self.all_flags(buzz_id, user)
    flags = []
    #buzz = Buzz.find_by_id(buzz_id)
    buzz = Buzz.find(buzz_id)
    self.where("id > ?", 1).each{|flag| flags << {:flag => flag, :expiry_date => buzz.buzz_flag_expiry_date(flag, user, "%Y-%m-%d"), :buzz_flag_checked => buzz.buzz_flag_checked(buzz, flag, user)}}
    flags
  end
  ########################### previously the below methods are in flag model end #####################################

  ########################### previously the below methods are in buzz flag model start #####################################
  #This method is used for the mobile API
  def self.save_buzz_flags(buzz_id, user, buzz_flags)
    buzz = Buzz.where(:id => buzz_id)
    BuzzFlag.destroy_all(:buzz_id => buzz_id, :user_id=> user.id)
    buzz_flags.each do |buzz_flag_attr|
      buzz.buzz_flags.create(buzz_flag_attr.merge(:user_id => user.id)) if buzz_flag_attr.include? ('flag_id')
    end
  end
  ########################### previously the below methods are in buzz flag model end #####################################

  ########################### previously the below methods are in buzz tag model start #####################################
  #this is used for the mobile API for saving the buzz tags
  def self.save_buzz_tags(buzz, tags)
    tags.each{|t| BuzzTag.create(:buzz_id => buzz.id, :tag_id => t)}
  end
  ########################### previously the below methods are in buzz tag model end #####################################

  ########################### previously the below methods are in channel alias model start ###################################

  # adding alias to channel/CUG
  def self.add_alias(channel_alias, channel, is_cug, user)
    msg = []
    channel = Channel.where("name = ? and is_cug = ? and is_active = ?", channel, is_cug, true).first
    if channel.nil?
      msg << "$#{is_cug ? 'CUG' : 'Channel'} doesn't exist or is inactive."
      success_status = false
    else
      if channel.is_admin?(user) || channel.is_subscribed?(user)
        channelalias = ChannelAlias.new(:channel_id => channel.id, :user_id => user.id, :name => channel_alias)
        if channelalias.save
          msg << "#{channel.channel_or_cug} alias #{channel_alias} added successfully"
          success_status = true
        else
          channelalias.errors.each do |attr, e|
            msg << "$#{e}" unless msg.include?(e)
            success_status = false
          end
        end
      else
        msg << "$You must be subscribed to or owner of the #{channel.channel_or_cug}"
        success_status = false
      end
    end
    return msg, success_status
  end

  ########################### previously the below methods are in channel alias model end ###################################

  ########################### previously the below methods are in Subscription model start ###################################
  def self.subscribe_me(channel, user)
    msg = []
    success_status = false
    return "$You cannot subscribe to your own #{channel.channel_or_cug}" if  channel.user_id == user.id

    subscription = Subscription.new(:channel_id => channel.id, :user_id => user.id, :is_core => channel.is_cug ? true : false)
    subscription.errors.each{|attr, val| msg << "$#{val}" unless msg.include?(val)} unless subscription.save
    if msg.blank?
      msg << "You have been subscribed successfully to #{channel.channel_or_cug}  #{channel.name}"
      success_status = true
    end
    return msg, success_status
  end

  def self.unsubscribe_me(channel, user)
    msg = []
    success_status = false
    return "$You cannot unsubscribe to your own #{channel.channel_or_cug}" if  channel.user_id == user.id

    subscription = Subscription.where(:channel_id => channel.id, :user_id => user.id).first
    if subscription.nil?
      msg << "$You are not subscribed to #{channel.name}"
    else
      subscription.destroy
    end
    if msg.blank?
      msg << "You have been successfully unsubscribed from #{channel.channel_or_cug} #{channel.name}"
      success_status = true
    end
    return msg, success_status
  end

  def self.subscribe_users(channel, users)
    msg = []
    success_status = false
    users_name = ""
    invalid_users = ""
    users.each do |email|
      email = User.append_domain(email)
      #user = User.find_by_email email
      user = User.where(:email => email).first
      if !user.nil?
        if channel.user_id != user.id
          if Subscription.where(:channel_id => channel.id, :user_id => user.id).count > 0
            msg << "#{user.full_name} is already subscribed to this #{channel.channel_or_cug}"
          else
            subscription = Subscription.new(:channel_id => channel.id, :user_id => user.id, :is_core => channel.is_cug ? true : false)
            if subscription.save
              users_name += user.full_name + ", "
            else
              subscription.errors.full_messages.each{|e| msg << "$#{e}" unless msg.include?(e)}
            end
          end
        else
          msg << "$You cannot subscribe to your own #{channel.channel_or_cug}"
        end
      else
        invalid_users += email + ", "
      end
    end
    msg << "#{users_name[0, users_name.length - 2]} added successfully to the #{channel.channel_or_cug} #{channel.name}" if !users_name.blank?
    if !invalid_users.blank?
      msg << "$#{invalid_users[0, invalid_users.length - 2]} not found"
    else
      msg << "You have been subscribed successfully" if msg.blank?
      success_status = true
    end
    return msg, success_status
  end


  def self.unsubscribe_users(channel, users)
    msg = []
    success_status = false
    users.each do |email|
      email = User.append_domain(email)
      #user = User.find_by_email email
      user = User.where(:email => email).first
      if user.nil?
        msg << "$User with email id #{email} does not exist"
      else
        if channel.user_id != user.id
          subscription = Subscription.where(:channel_id => channel.id, :user_id => user.id).first
          if !subscription.nil?
            subscription.destroy
            msg << "#{user.full_name} has been unsubscribed from #{channel.channel_or_cug} #{channel.name}"
            success_status = true
          else
            msg << "$#{user.full_name} has not subscribed to #{channel.channel_or_cug} #{channel.name}"
          end
        else
          msg << "$You cannot unsubscribe to your own #{channel.channel_or_cug}"
        end
      end
    end
    if msg.blank?
      msg << "You have successfully unsubscribed the users "
      success_status = true
    end
    return msg, success_status
  end

  def set_last_viewed
    self.last_viewed = Time.now
    self.save
  end

  def status
    is_core ? "Core" : "Peripheral"
  end
  
  ########################### previously the below methods are in Subscription model end ###################################

  ########################### previously the below methods are in Tag model start ###################################
  # This is used for the mail processing
  def self.add_tag(apply_to, channel_name, process_values, user)
    msg = []
    success_status = true
    if !process_values.empty?
      if apply_to == 'channel'
        channel = Channel.where(:name => channel_name, :is_cug => false, :is_active => true).first
      else
        channel = Channel.joins(:channel_aliases).where("channel_aliases.name = ? and is_cug = ? and channels.is_active = ?", channel_name, false, true).first
      end
      if !channel.nil?
        if channel.is_admin?(user)
          process_values.each do |tag_name|
            if Tag.where(:channel_id => channel.id, :name => tag_name).first
              msg << "$tag name #{tag_name} is already exist"
              success_status = false
            else
              Tag.create(:channel_id => channel.id, :name => tag_name)
            end
          end
        else
          msg << "$You must be a moderator of the #{channel.channel_or_cug}"
          success_status = false
        end
      else
        msg << "$#{apply_to == 'channel' ? 'Channel' : 'CUG'} not found or is inactive or you are not a moderator of the #{apply_to == 'channel' ? 'Channel' : 'CUG'}"
        success_status = false
      end
      msg << "Tags added successfully to #{channel.channel_or_cug} #{channel.name}" if msg.blank?
    else
      msg << "$Please provide tag names"
      success_status = false
    end
    return msg, success_status
  end
  ########################### previously the below methods are in Tag model end ###################################

  ########################### previously the below methods are in Watch channel model end ###################################
  # I think this method is not using anywhere in new version
  def self.add_fav(apply_to, channel_name, is_cug, user)
    msg = []
    success_status = false
    if apply_to == 'alias'
      channel = Channel.joins(:channel_aliases).where("channel_aliases.name = ? and channels.is_active = ?", channel_name, true).first
    else
      channel = Channel.where("name = ? and is_cug = ? and is_active = ?", channel_name, is_cug, true).first
    end

    if !channel.nil?
      if channel.is_admin?(user) || channel.is_subscribed?(user)
        favourate = WatchChannel.new(:channel_id => channel.id, :user_id => user.id)
        if favourate.save
          msg << "#{channel.channel_or_cug} #{channel.name} has been added successfully to your watch list"
          success_status = true
        else
          favourate.errors.full_messages.each{|e| msg << "$#{e}" unless msg.include?(e)}
        end
      else
        msg << "$You must be subscribed to or owner of the #{channel.channel_or_cug} #{channel.name}"
      end
    else
      msg << "$#{is_cug ? 'CUG' : 'Channel'} doesn't exist or is inactive"
      success_status = false
    end
    return msg, success_status
  end

  # I think this method is not using anywhere in new version
  def self.add_to_watch(channel,user)
    msg = []
    favourate = WatchChannel.new(:channel_id => channel.id, :user_id => user.id)
    if favourate.save
      msg << "#{channel.channel_or_cug} #{channel.name} has been added to your watch list"
    else
      favourate.errors.full_messages.each{|e| msg << "$#{e}" unless msg.include?(e)}
    end
    return msg
  end

  # I think this method is not using anywhere in new version
  def self.remove_from_watch(channel,user)
    watch_channel = WatchChannel.where(:channel_id => channel.id, :user_id => user.id).first
    watch_channel.delete
    "#{channel.channel_or_cug} #{channel.name} has been removed from your watch list"
  end
  ########################### previously the below methods are in Watch channel model end ###################################

  ########################### previously the below methods is used for the auto responce message for the mailman start########
  def autoresponse_msg(msg)
    message = ""
    return message if (msg.nil? || msg.blank?)
    if msg.is_a?(Array)
      msg.each do |m|
        message += "#{m[0,1]=='$' ? m[1,m.length] : m}" + ", "
      end
      message = message[0, message.length - 2]
    else
      message = "#{msg[0,1]=='$' ? msg[1,msg.length] : msg}"
    end
    message
  end
  ########################### previously the below methods is used for the auto responce message for the mailman end########
end