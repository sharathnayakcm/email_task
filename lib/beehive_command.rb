module BeehiveCommand
  GROUP_TYPE = {
    'channel'   => '#',
    'cug'       => '@'
  }

  COMMAND_LEVEL_1 = {
    'buzzout'           =>  'b',
    'add_channel_1'     =>  '+',
    'add_channel_2'     =>  'c',
    'subscription_1'    =>  's',
    'subscription_2'    =>  '>',
    'unsubscription_1'  =>  'u',
    'unsubscription_2'  =>  '<',
    'tag_1'             =>  't',
    'tag_2'             =>  '%',
    'merge'             =>  'm',
    'destruction_1'     =>  '-',
    'destruction_2'     =>  'd',
    'watch'             =>  'w',
    'find'              =>  'f',
    'rezz_buzzout'      =>  'r'
  }

  COMMAND_LEVEL_2 = {
    'channel'   => '#',
    'cug'       => '@',
    'alias'     => '/',
    'buzz'      => 'b',
    'insync'    => 'i'
  }
  
  BUZZ_TO = {
    'channel'   => '#',
    'cug'       => '@',
    'alias'       => '/'
  }


  def chk_format(command_value)
    if COMMAND_LEVEL_1.value?(command_value[0,1].downcase) && COMMAND_LEVEL_2.value?(command_value[1,1].downcase)
      return true
    elsif BUZZ_TO.value?(command_value[0,1].downcase)
      return true
    else
      return false
    end
  end

  def is_here_command?(command)
    return false if command.strip == ""
    flag = false
    command = command.split(' ')
    apply_to = command[0][0,1]
    if apply_to == '#' || apply_to == '@'
      if command[0][1,command[0].length].downcase == 'here'
        flag = true
      end
    end
    return flag
  end

  def is_here_command_for(command)
    command = command.split(' ')
    apply_to = command[0][0,1]
    channel_type = (apply_to == '#' ? 'channel' : 'cug')
    command_here = command[0][0,command[0].length]
    return channel_type, command_here
  end

  def process_here_command(command, attachment, channel = nil)
    channel_type, command_here = is_here_command_for(command)
    is_cug = (channel_type == 'cug')
    if channel.nil?
      {:show_data => false, :task => 'invalid_here', :process_msg => "$'#{command_here}' can be used only when you are in #{is_cug ? 'CUG' : 'Channel'} listing page"}
    elsif channel.is_cug == is_cug
      command = command.gsub("\n","<br/>").split(' ')
      command[0] = command[0].gsub(command[0][1,command[0].length],channel.name)
      command = command.join(' ').rstrip
      process_command_task(command,attachment)
    else
      {:show_data => false, :task => 'invalid_here', :process_msg => "$'#{command_here}' can be used only when you are in  #{is_cug ? 'CUG' : 'Channel'} listing page."}
    end
  end

  def process_command_task(command_value, attachment = nil)
    direct_buzz_out = BUZZ_TO.value?(command_value[0,1].downcase) ? true : false
    if direct_buzz_out
      task = "buzzout"
      apply_to = BUZZ_TO.key(command_value[0,1].downcase)
      command_value = command_value.slice!(1..command_value.length)
    else
      task = COMMAND_LEVEL_1.key(command_value[0,1].downcase)
      apply_to = COMMAND_LEVEL_2.key(command_value[1,1].downcase)
      if task == "rezz_buzzout"
        regexp = command_value.match(/^r[@,#]([^ ]*) (\d+) ((.|\n|.)*)$/)
        buzz_id = regexp[2]
        command_value = regexp[1] + " " + regexp[3]
     else
        command_value = command_value.slice!(2..command_value.length)
      end    
    end
    # if command is for buzzout then we will replace the newline("\n") with "<br/>" so that it will display as line break in view
    # but the logic is to replace "<br/>" with new line while saving into the db. So, that it would not effect in mobile version for now.
    process_values = (["buzzout", "rezz_buzzout"].include?(task)) ? command_value.gsub("\n","<br/>").split(' ') : command_value.split(' ')
    process_command_values(task, apply_to, process_values, attachment, buzz_id)
  end

  def process_command_values(task, apply_to, process_values=nil, attachment = nil,buzz_id = nil)
    if task=='add_channel_1' || task=='add_channel_2'
      {:show_data => false, :task => 'add_channel', :process_msg => process_channel(apply_to,process_values), :apply_to => apply_to}
    elsif task=='destruction_1' || task=='destruction_2'
      {:show_data => false, :task => 'remove_channel', :process_msg => process_remove_channel(apply_to,process_values), :apply_to => apply_to}
    elsif task=='tag_1' || task=='tag_2'
      {:show_data => false, :task => 'tag', :process_msg => process_tag(apply_to,process_values), :apply_to => apply_to}
    elsif task=='subscription_1' || task=='subscription_2'
      {:show_data => false, :task => 'subscription', :process_msg => process_subscription(apply_to,process_values), :apply_to => apply_to}
    elsif task=='unsubscription_1' || task=='unsubscription_2'
      {:show_data => false, :task => 'unsubscription', :process_msg => process_unsubscription(apply_to,process_values), :apply_to => apply_to}
    elsif task == 'buzzout' || task == "rezz_buzzout"
      {:show_data => false, :task => task, :process_msg => process_buzzout(apply_to, process_values, attachment,buzz_id), :apply_to => apply_to}
    elsif task=='find'
      {:show_data => true, :task => task, :apply_to => apply_to, :process_values => process_values}
    elsif task=='watch'
      {:show_data => false, :task => task, :process_msg => process_watch(apply_to,process_values), :apply_to => apply_to}
    elsif task=='merge'
      {:show_data => false, :task => task, :process_msg => process_merge(apply_to,process_values), :apply_to => apply_to}
    end
  end

  def process_channel(apply_to,process_values)
    msg = ""
    success_status = false
    if apply_to == 'channel'
      is_cug = false
      msg, success_status = process_channels_add(process_values, is_cug)
    elsif apply_to == 'cug'
      is_cug = true
      msg, success_status = process_channels_add(process_values, is_cug)
    elsif apply_to == 'alias'
      msg, success_status = process_alias_add(process_values)
    end
    {:msg => msg, :success_status => success_status}
  end

  def process_buzzout(apply_to, process_values, attachment = nil,buzz_id = nil)
    msg = ""
    channel_id = 0
    success_status = false
    is_cug = (apply_to == 'cug')
    channel_name = process_values.shift
    buzz_msg = process_values.join(' ').rstrip
    priority = buzz_msg[0,1] == "!" ? true : false
    buzz_msg = priority ? buzz_msg[1,buzz_msg.length].gsub("<br/>","\n") : buzz_msg.gsub("<br/>","\n")
    if apply_to == 'channel' || apply_to == 'cug' || apply_to == 'alias'
      if buzz_id != nil
        msg, channel_id, success_status = Buzz.channel_rezzout(channel_name, is_cug, buzz_msg, priority, current_user, apply_to, attachment, buzz_id)         
      else
        msg, channel_id, success_status = Buzz.channel_buzzout(channel_name, is_cug, buzz_msg, priority, current_user, apply_to, attachment)
      end
    end
    {:msg => msg, :channel_id => channel_id, :success_status => success_status}
  end

  def process_subscription(apply_to,process_values)
    msg = ""
    success_status = false
    channel_id = 0
    is_cug = (apply_to == 'cug')
    channel_name = process_values.shift
    channel = Channel.where("name = ? and is_cug = ? and is_active = ?", channel_name, is_cug, true).first
    if !channel.nil?
      channel_id = channel.id
      if process_values.count > 0
        msg, success_status = (channel.user_id == current_user.id) ? Subscription.subscribe_users(channel, process_values) : "$You must be the admin/ owner of this channel to add users"
      elsif !is_cug
        msg, success_status = Subscription.subscribe_me(channel, current_user)
      elsif process_values.count == 0 && is_cug
        msg = "$Only admin/ moderator of a CUG can subscribe the user. You can't subscribe yourself to a CUG"
      end
    else
      msg = "$#{is_cug ? 'CUG' : 'Channel'} doesn't exist or is inactive"
      success_status = false
    end
    {:msg => msg, :channel_id => channel_id, :success_status => success_status}
  end

  def process_unsubscription(apply_to,process_values)
    msg = ""
    success_status = false
    is_cug = (apply_to == 'cug')
    channel_name = process_values.shift
    if apply_to == 'alias'
      channel = Channel.joins(:channel_aliases).where("channel_aliases.name = ? and channels.is_active = ?", channel_name, true).first
    else
      channel = Channel.where("name = ? and is_cug = ? and is_active = ?", channel_name, is_cug, true).first
    end
    if !channel.nil?
      if process_values.count > 0
        msg, success_status =  channel.user_id == current_user.id ? Subscription.unsubscribe_users(channel, process_values) : "$You must be the admin/ owner of this #{is_cug ? 'CUG' : 'Channel'} to unsubscribe users"
      else
        msg = "$Please provide emails to unsubscribe"
      end
    else
      msg = "$#{is_cug ? 'CUG' : 'Channel'} doesn't exist or is inactive or you are not the moderator of #{is_cug ? 'CUG' : 'Channel'}"
    end
    {:msg => msg, :success_status => success_status}
  end

  def process_channels_add(channels, is_cug)
    Channel.add_channels(channels, current_user, is_cug)
  end

  def process_cugs_add(channels)
    Channel.add_cugs(channels, current_user)
  end

  def process_alias_add(process_values)
    return "$Invalid command" unless process_values.count > 1

    channel_alias = process_values[0]
    group_symbol = process_values[1][0,1]
    channel = process_values[1].slice!(1..process_values[1].length).rstrip
    if GROUP_TYPE.value?(group_symbol)
      group_type = GROUP_TYPE.key(group_symbol)
      add_alias_to_channel(channel_alias, channel, group_type)
    else
      "$Invalid command"
    end
  end

  def add_alias_to_channel(channel_alias, channel, channel_type)
    is_cug = (channel_type == 'cug')
    ChannelAlias.add_alias(channel_alias, channel, is_cug, current_user)
  end

  def process_tag(apply_to, process_values)
    msg = ""
    success_status = false
    channel_name = process_values.shift
    if apply_to == 'channel' || apply_to == 'alias'
      msg, success_status  = Tag.add_tag(apply_to, channel_name, process_values, current_user)
    else
      msg = "$Invalid command"
      success_status = false
    end
    {:msg => msg, :success_status => success_status}
  end

  def process_find(apply_to,process_values)
    if !process_values.nil?
      if apply_to == 'channel' || apply_to == 'cug'
        is_cug = (apply_to == 'cug')
        search_text = !process_values.nil? ? process_values.join(' ') : []
        {:search_type => 'all_channel_search', :search_data => Channel.all_channels_search(search_text, is_cug, current_user)}
      elsif apply_to == 'buzz'
        if !process_values.last.nil? && COMMAND_LEVEL_2.value?(process_values.last[0,1])
          command_last_option = process_values.pop
          is_cug = (COMMAND_LEVEL_2.key(command_last_option[0,1]) == 'cug')
          is_alias = (COMMAND_LEVEL_2.key(command_last_option[0,1]) == 'alias')
          search_channel_name = command_last_option[1,command_last_option.length]
          search_text = !process_values.nil? ? process_values.join(' ') : []
          {:search_type => 'channel_search', :search_data => Channel.buzz_channels_search(search_text, is_cug, is_alias, search_channel_name, current_user)}
        else
          search_text = !process_values.nil? ? process_values.join(' ') : []
          {:search_type => 'channel_search', :search_data => Channel.buzz_channels_cugs_search(search_text, current_user)}
        end
      end
    else
      {:search_type => 'channel_search', :search_data => []}
    end
  end

  def process_insync(apply_to,process_values)
    if !process_values.nil?
      if apply_to == 'insync'
        process_values = !process_values.nil? ? process_values.join(' ') : ""
        is_cug = (COMMAND_LEVEL_2.key(process_values[0,1]) == 'cug')
        if is_cug
          channel_name = process_values[1,process_values.length]
          channel = Channel.where("name = ? and is_cug = ? and user_id = ? and channels.is_active = ?", channel_name, is_cug, current_user.id, true).first
          if !channel.nil?
            {:search_type => 'insync_search', :search_data => channel.insync_search, :search_message => 'Command successful.'}
          else
            {:search_type => 'insync_search', :search_data => [], :search_message => "$This CUG doesn't exists or is inactive or you are not the owner of this channel"}
          end
        else
          {:search_type => 'insync_search', :search_data => [], :search_message => '$Invalid command.'}
        end
      end
    else
      {:search_type => 'channel_search', :search_data => [], :search_message => '$Invalid command.'}
    end
  end

  def process_watch(apply_to,process_values)
    msg = ""
    success_status = false
    is_cug = (apply_to == 'cug')
    channel_name = process_values.shift
    if !channel_name.blank?
      msg, success_status = WatchChannel.add_fav(apply_to, channel_name, is_cug, current_user)
    else
      msg = "$Please provide channel/cug name or channel alias"
    end
    {:msg => msg, :success_status => success_status}
  end

  def process_merge(apply_to,process_values)
    msg = ""
    success_status = false
    cug_name = process_values.shift
    channel_name = process_values.shift
    if apply_to != 'cug' || cug_name.blank? || channel_name.blank?
      ["$Invalid Command"]
      success_status = false
    else
      msg, success_status = ChannelAssociation.merge_channels(cug_name, channel_name, current_user)
    end
    {:msg => msg, :success_status => success_status}
  end

  def process_remove_channel(apply_to,process_values)
    msg = ""
    success_status = false
    is_cug = (apply_to == 'cug')
    channel_name = process_values.shift
    if !channel_name.blank?
      msg, success_status = Channel.remove_channel(apply_to,channel_name,is_cug,current_user)
    else
      msg = "$Please provide channel/cug name or channel alias"
      success_status = false
    end
    {:msg => msg, :success_status => success_status}
  end

  def api_command_message(msg)
    message = ""
    return message if msg.blank?

    if msg.is_a?(Array)
      msg.each do |m|
        message += (m[0,1] == "$" ? m[1,m.length] : m) + " -"
      end
      message = message[0, message.length-1]
    else
      message = msg[0,1] == "$" ? msg[1,msg.length] : msg
    end
    message.html_safe
  end
end

