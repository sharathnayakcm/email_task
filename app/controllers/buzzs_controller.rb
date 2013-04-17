class BuzzsController < ApplicationController
  # befor_filter :ajax_request_rescue

  def index
    @channel = Channel.find(params[:channel_id])
    if @channel.is_cug
      @buzzs, @last_insync_id = Channel.get_buzzs(@channel.id, current_user.id, "false", 10, params[:page] || 1)
      @buzzs, @last_insync_id =  Channel.get_buzzs(@channel.id, current_user.id, "true", 10, params[:page] || 1) if @buzzs.blank?
    else
      subscription = Subscription.where(:channel_id => @channel.id, :user_id => current_user.id).first
      subscription.update_attributes(:last_viewed => Time.now) if subscription
      @buzzs = Channel.get_channel_buzzs(@channel.id, 10, params[:page] || 1)
    end
    respond_to do |format|
      format.js
      format.html { redirect_to channels_path}
    end
  end


  def filter_buzzs
    @channel = Channel.find(params[:channel_id])
    view_type = if (params[:show_out_insync] && params[:show_in_insync])
      "both"
    elsif(params[:show_out_insync])
      "false"
    else
      "true"
    end
    buzzs, @last_insync_id =  Channel.get_buzzs(@channel.id, current_user.id, view_type, @channel.buzzs.count, 1)
    @buzzs = Buzz.check_filters(params, buzzs, current_user.id).paginate(:page => params[:page] || 1, :per_page => 10)
    respond_to do |format|
      format.js { render :template => 'buzzs/index.js.erb'}
      format.html { redirect_to channels_path}
    end
  end
  
  #viewing a buzz which is related to a buzz task
  def show
    @buzz = Buzz.where(:id => params[:id]).first
    @channel = Channel.where(:id => params[:channel_id]).first

  end

  def new
    @buzz = Buzz.new
    if params[:channel_id]
      @channel = Channel.where(:id => params[:channel_id]).first
      @user_names = @channel.subscribed_users.select("users.id, users.first_name, users.last_name, users.display_name").where("users.id != #{current_user.id}")
    end
    respond_to do |format|
      format.js
      format.html { redirect_to channels_path}
    end
  end

  def create
    if params[:buzz][:channel_id].to_i == 0
      @channel = Channel.where(:name => params[:channel_name]).first
      params[:buzz].merge!(:channel_id => @channel.id) unless @channel.blank?
    else
      @channel = Channel.find(params[:buzz][:channel_id])
    end
    if @channel
      if @channel.is_admin?(current_user) || @channel.is_subscribed?(current_user)
        @buzz = current_user.buzzs.new(params[:buzz])
        @buzz.buzz_names.build(params[:buzz_name]) unless params[:buzz_name].blank? || params[:buzz_name][:name].blank?
        if @buzz.save
          #save_buzz_properties(@buzz, params)
          save_users(@buzz, params)
          flash.now[:notice] = "Buzzed out to #{@channel.channel_or_cug} \"#{@channel.name}\" successfully"
        else
          msg = []
          flash.now[:error] = @buzz.errors.full_messages.each{|e| msg << "#{e}" unless msg.include?(e)}
        end
      else
        flash.now[:error] = "You must be subscribed to or owner of the #{@channel.channel_or_cug} #{@channel.name}"
      end
    else
      flash.now[:error] = "Channel or CUG doesn't exit, please select appropriate one."
    end
  end

  def more_buzzs
    @channel = Channel.where(:id => params[:id]).first
    @channel.is_cug? ? (@buzzs, @last_insync_id = Channel.get_buzzs(@channel.id,current_user,params[:hide_insync_cugs], 5, params[:page])) : @buzzs = @channel.buzzs.paginate(:page => params[:page] || 1, :per_page => 5)
    respond_to do |format|
      format.js
      format.html { redirect_to channels_path}
    end
  end

  def insync_buzz_in_channel
    @channel = Channel.find(params[:id])
    BuzzInsync.insync(@channel.id, params[:buzz_id], current_user)
    PriorityBuzz.update_all({:insync => true}, "buzz_id <= #{params[:buzz_id]} and user_id = #{current_user.id}")
  end

  def limit_user
    @buzz = Buzz.find(params[:buzz_id])
    priority_buzz_users = @buzz.priority_buzzs.where("priority_buzzs.insync = false").map(&:user_id)
    response_buzz_users = @buzz.response_expected_buzzs.map(&:user_id)
    priority_response_users = priority_buzz_users + response_buzz_users
    if params[:user_ids].blank? || priority_response_users.empty? || (priority_response_users && params[:user_ids] && (priority_response_users - params[:user_ids].map(&:to_i)).blank?)
      user_ids = params[:user_ids].push(@buzz.user_id) unless params[:user_ids].blank?
      flash.now[:notice] = BuzzMember.limit_members(@buzz, user_ids)
    else
      @ids = priority_response_users
      flash.now[:error] = "You cannot limit the buzz, Priority (or) Response Expected has been set for some users."
    end
  end

  #limiting a buzz to the members in the channel
  def limit_buzz
    channel = Channel.find(params[:channel_id])
    @user_names = channel.subscribed_users.where("users.id != #{current_user.id}")
    @buzz = channel.buzzs.where(:id => params[:buzz_id]).first
  end


  def save_users(buzz, params)
    #save priority users buzz
    unless params[:prioritize_user_ids].blank?
      params[:prioritize_user_ids].scan(/\d+/).each do |user_id|
        buzz.priority_buzzs.create({:user_id => user_id, :owner_id => current_user.id})
      end
    end

    #save response expected users buzz
    unless params[:response_expected].blank?
      params[:response_expected].scan(/\d+/).each do |user_id|
        buzz.response_expected_buzzs.create({:user_id => user_id, :owner_id => current_user.id})
      end
    end
    
    #save limit buzz
    unless params[:information_user_ids].blank?
      user_ids = params[:information_user_ids].scan(/\d+/).push(current_user.id)
      if buzz.channel.subscribed_users.map(&:id).count != user_ids.count
        user_ids.each do |user_id|
          buzz.buzz_members.create({:channel_id => buzz.channel_id, :user_id => user_id})
        end
      end
    end
  end

  #search channels for adding a buzz
  def channel_search
    is_cug =  params[:channel] == "true" ? true:false
    channels  = Channel.includes(:channel_aliases, :subscriptions => :user).searched_channels(is_cug, params[:query], current_user.id)
    render :json => { :query => params[:query],
      :suggestions => channels.blank? ? ["No #{params[:is_channel_view]== "true" ? "Channels" : "CUGs"} Found"] : channels.map{|channel| "#{ChannelAlias.select("name,id").where(:user_id => current_user.id, :channel_id => channel.id).first.try(:name) || channel.name}"},
      :data => channels.blank? ? [0] : channels.map{|channel| channel.id} }
  end

  def user_has_priority_response_expected
    priority_buzz_users = PriorityBuzz.select("id").where(:buzz_id => params[:buzz_id], :user_id => params[:user_id], :insync => false).map(&:id)
    response_buzz_users = ResponseExpectedBuzz.select("id").where(:buzz_id => params[:buzz_id], :user_id => params[:user_id]).map(&:id)
    priority_response_users = priority_buzz_users + response_buzz_users
    render :text => priority_response_users.blank?
  end

  def get_channel
    @channel = Channel.select("id").where(:id => params[:id]).first
    @user_names = @channel.subscribed_users.delete_if{|user| user.id == current_user.id}
  end
end
