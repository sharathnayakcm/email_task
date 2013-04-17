class Api::ChannelsController < Api::BaseController
  before_filter :get_resource

  def create
    if !@resource.nil?
      mess, success_status = Channel.add_channels(params[:name].split(' '), current_user, true)
      render :json => {:success => success_status, :message => mess, :name => params[:name]}
    else
      render :json=> {:success=>false, :message=>"Unauthorized access", :name => params[:name]}, :status=>401
    end
  end

  def get_detail
    channel_data = []
    filter_type = 0
    message = ""
    #    resource = User.find_for_database_authentication(:email=>params[:user][:email], :authentication_token => params[:user][:auth_token])
    if !@resource.nil?
      case params[:filter]
      when 'by_Watch'
        channel_data = @resource.watch_channels_buzzes_api
        filter_type = 0
      when 'My_Channels'
        channel_data = @resource.my_channels
        filter_type = 1
      when 'Other_Channels'
        channel_data = @resource.other_channels
        filter_type = 1
      when 'New_Channels'
        channel_data = @resource.new_channels
        filter_type = 1
      when 'CoreCUGs'
        channel_data = @resource.core_peripheral_cugs('Core')
        filter_type = 2
      when  'PeriCUGs'
        channel_data = @resource.core_peripheral_cugs('Peri')
        filter_type = 2
      when 'by_Today'
        filter_type = 3
        channel_data = @resource.today_buzzes_api
      when 'by_Calendar'
        filter_type = 4
        start_date = params[:start_date]
        end_date = params[:end_date]
        date_diff = (Date.parse(end_date) - Date.parse(start_date)).to_i
        if Date.parse(start_date) <= Date.today && Date.parse(end_date) <= Date.today
          if Date.parse(start_date) <= Date.parse(end_date)
            if date_diff <= APP_CONFIG['date']['max_calendar_days_diff'].to_i
              channel_data = @resource.calendar_buzzes_api(start_date, end_date)
              message = "No buzzes found for selected dates" unless channel_data.count > 0
            else
              message = "Date difference should not exceed #{APP_CONFIG['date']['max_calendar_days_diff']} days"
            end
          else
            message = "Please enter valid date range"
          end
        else
          message = "Date should not be greater then today's date"
        end
      end      
      render :json=> {:success=>true, :channels => channel_data, :filter_type => filter_type, :message => message}
    else
      render :json=> {:success=>false, :message=>"Unauthorized access", :filter_type => filter_type}, :status=>401
    end
  end

  def swap_cug_type
    #    resource = User.find_for_database_authentication(:email=>params[:user][:email], :authentication_token => params[:user][:auth_token])
    if !@resource.nil?
      #channel = Channel.find_by_id(params[:channel_id])
      channel = Channel.find(params[:channel_id])
      message = channel.change_cug_type(current_user,params[:type])
      render :json => {:success => true, :message=> message}
    else
      render :json => {:success =>false, :message=>"Unauthorized access"}, :status=>401
    end
  end

  def get_channel_detail
    buzzes = []
    #    resource = User.find_for_database_authentication(:email=>params[:user][:email], :authentication_token => params[:user][:auth_token])
    if !@resource.nil?
      channel = Channel.find(params[:id])
      if !channel.nil?
        channel_data = {
          :id => channel.id,
          :name => channel.name,
          :description => channel.description,
          :moderator => channel.moderator?(@resource),
          :buzzers => channel.buzzers,
          :active_buzzers => channel.active_buzzers,
          :owner => channel.is_owner?(@resource),
          :subscribed => channel.is_subscribed?(@resource),
          :buzz_rate_1 => @resource.buzz_rate_1,
          :buzz_rate_1_count => channel.buzz_rate_count(@resource.buzz_rate_1),
          :buzz_rate_2 => @resource.buzz_rate_2,
          :buzz_rate_2_count => channel.buzz_rate_count(@resource.buzz_rate_2),
          :buzzes => channel.buzzes_list(@resource, params[:criteria],params[:filter1],params[:filter2]),
          :is_cug => channel.is_cug,
          :involvement => channel.is_cug ? channel.cug_status(@resource) : '',
          :core => channel.is_cug ? channel.type_buzzers(true) : '',
          :peripheral => channel.is_cug ? channel.type_buzzers(false) : ''
        }
        channel.set_last_viewed(@resource)
        render :json=> {:success=>true, :channel => channel_data}
      else
        render :json=> {:success=>false, :message=> api_command_message(channel.errors.full_messages)}, :status=>401
      end
    else
      render :json=> {:success=>false, :message=>"Unauthorized access"}, :status=>401
    end
  end

  def get_moderator_list
    if !@resource.nil?
      @list = params[:is_cug].to_s == 'true' ? {:cugs => @resource.owner_cugs} : {:channels => @resource.owner_channels}
      render :json=> {:success=>true, :channels => @list}
    else
      render :json=> {:success=>false, :message=>"Unauthorized access"}, :status=>401
    end
  end

  def get_moderator_channel_detail
    if !@resource.nil?
      channel = Channel.find(params[:id])
      if !channel.nil?
        channel_data = {
          :id => channel.id,
          :name => channel.name,
          :status => channel.status,
          :description => channel.description,
          :total_buzzes => channel.total_buzzes,
          :last_seven_days_buzzes_count => channel.channel_buzzes_count(7.days.ago),
          :today_buzzes_count => channel.today_buzzes_count,
          :tags => channel.tag_list,
          :created_date => channel.created_at.strftime("%d %b %Y"),
          :is_cug => channel.is_cug
        }
        render :json=> {:success=>true, :channel => channel_data}
      else
        render :json=> {:success=>false, :message=> api_command_message(channel.errors.full_messages)}, :status=>401
      end
    else
      render :json=> {:success=>false, :message=>"Unauthorized access"}, :status=>401
    end
  end

  def subs_unsubscribe_channel
    if !@resource.nil?
      channel = Channel.find(params[:id])
      if !channel.nil?
        msg, success_status = params[:act] == 'Subscribe' ? Subscription.subscribe_me(channel, @resource) : Subscription.unsubscribe_me(channel, @resource)
        render :json=>  {
          :success => success_status,
          :message => api_command_message(msg)
        }
      else
        render :json=> {:success=>false, :message => api_command_message(channel.errors.full_messages)}, :status=>401
      end
    else
      render :json=> {:success=>false, :message=>"Unauthorized access"}, :status=>401
    end
  end

  def close_channel
    if !@resource.nil?
      channel = Channel.find(params[:id])
      if !channel.nil?
        channel.update_attributes(:is_active => false)
        render :json=>  {:success=>true, :message => "#{channel.name} has been closed successfully"}
      else
        render :json=> {:success=>false, :message => api_command_message(channel.errors.full_messages)}, :status=>401
      end
    else
      render :json=> {:success=>false, :message=>"Unauthorized access"}, :status=>401
    end
  end

  def update_channel
    if !@resource.nil?
      channel = Channel.find(params[:channel][:id])
      if !channel.nil?
        if channel.update_attributes(:name => params[:channel][:name], :description => params[:channel][:description])
          render :json=>  {:success=>true, :message => "#{channel.name} has been updated successfully"}
        else
          render :json=> {:success=>false, :message => api_command_message(channel.errors.full_messages), :channel => channel}, :status=>401
        end
      else
        render :json=> {:success=>false, :message => api_command_message(channel.errors.full_messages)}, :status=>401
      end
    else
      render :json=> {:success=>false, :message=>"Unauthorized access"}, :status=>401
    end
  end

  def channel_buzzers
    if !@resource.nil?
      channel = Channel.find(params[:id])
      if !channel.nil?
        render :json=>  {:success=>true, :message => "", :data => channel.buzzers_list}
      else
        render :json=> {:success=>false, :message => api_command_message(channel.errors.full_messages)}, :status=>401
      end
    else
      render :json=> {:success=>false, :message=>"Unauthorized access"}, :status=>401
    end
  end

  def delete_buzz
    if !@resource.nil?
      render :json=>  {:success=>false, :message => api_command_message(Buzz.remove_buzz(params[:id])), :channel_id => params[:channel_id]}
    else
      render :json=> {:success=>false, :message=>"Unauthorized access", :channel_id => params[:channel_id]}, :status=>401
    end
  end

  def get_cug_contribution
    if !@resource.nil?
      channel = Channel.find(params[:id])
      if !channel.nil?
        is_core = (params[:type] == 'Core')
        render :json=> {:success=>true, :contributors => channel.buzzers_list(is_core)}
      else
        render :json=> {:success=>false, :contributors => []}, :status=>401
      end
    else
      render :json=> {:success=>false, :contributors => [], :message=>"Unauthorized access"}, :status=>401
    end
  end
  
  def buzz_here
    if !@resource.nil?
      here_command = is_here_command?(params[:command])
      #channel = Channel.find_by_id(params[:channel_id])
      channel = Channel.find(params[:channel_id])
      if here_command
        process_command = process_here_command(params[:command], nil, channel)
        if process_command[:process_msg].class.to_s == "Hash"
          render :json => {:success => process_command[:process_msg][:success_status], :message => process_command[:process_msg][:msg], :channel_id => params[:channel_id], :process_result => process_command, :channel_name => channel.name, :command => params[:command], :is_cug => channel.is_cug}
        else
          render :json => {:success => false, :channel_id => params[:channel_id], :process_result => process_command, :message => process_command[:process_msg], :channel_name => channel.name, :command => params[:command], :is_cug => channel.is_cug}
        end
      else
        if params[:command] == ""
          message = "Please type #{channel.is_cug ? '@here' : '#here'} command and buzz" 
          render :json=> {:success=>false, :message => message, :channel_id => params[:channel_id], :channel_name => channel.name, :command => params[:command], :is_cug => channel.is_cug}
        else
          render :json=> {:success=>false, :message => "Invalid Command", :channel_id => params[:channel_id], :channel_name => channel.name, :command => params[:command], :is_cug => channel.is_cug}
        end
      end
    else
      render :json=> {:success=>false, :contributors => [], :message=>"Unauthorized access", :command => params[:command]}, :status=>401
    end
  end

  def channel_members
    if !@resource.nil?
      #channel = Channel.find_by_id(params[:id])
      channel = Channel.find(params[:id])
      buzz = channel.buzzs.find(params[:buzz_id])
      channel_members = channel.channel_members.collect{|u| {:id => u.id, :display_name => u.display_name}}
      channel_members.delete({:id => @resource.id, :display_name => @resource.display_name})
      render :json=> {:success=>true, :channel_id => params[:id], :members => channel_members, :buzz_members => (buzz.buzz_members.collect{|u| u.user_id.to_i} + buzz.buzzed_users).uniq}
    else
      render :json=> {:success=>false, :contributors => [], :message=>"Unauthorized access", :command => params[:command]}, :status=>401
    end
  end
  
  private
  
  def get_resource
    @resource = User.find_for_database_authentication(:email=>params[:user][:email], :authentication_token => params[:user][:auth_token])
  end
end