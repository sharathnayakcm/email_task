class CugsController < ApplicationController
  respond_to  :json
  layout 'dashboard', :except => :advance_search

  #cug edit
  def edit
    @channel = Channel.find(params[:id])
    @channel_aliases = [ @channel.channel_aliases.find_or_initialize_by_user_id(current_user.id) ]
    @fav_channel = [ @channel.watch_channels.find_or_initialize_by_user_id(current_user.id) ]
    @subscription =  @channel.subscriptions.includes(:user).where(:user_id => current_user.id).first
    @existing_members = @channel.subscribed_users.where("user_id != ?", current_user.id)
  end

  #searching members
  def search_members
    @users = User.select("id, email, concat(first_name,' ',last_name) as name").where("id != ? and (first_name LIKE ? or last_name LIKE ?)",current_user.id, "%#{params[:q]}%", "%#{params[:q]}%")
    render :text => @users.to_json
  end

  def search_cug_members
    @cug = Channel.find_by_id(params[:id])
    @users = @cug.subscribed_users.where("users.id != ? and (users.first_name LIKE ? or users.last_name LIKE ?)",current_user.id, "%#{params[:q]}%", "%#{params[:q]}%").map{|p| [p.id,p.display_name] }
    render :text => @users.to_json
  end
  #Update a cug
  def update
    @channel = Channel.includes([:subscriptions,:channel_aliases]).find(params[:id])

    if @channel.update_attributes(params[:channel])
      flash.now[:notice] = 'CUG details successfully updated'
    else
      flash.now[:error] =   @channel.errors.full_messages
    end

    #updating user_id if change of moderator request is sent
    @channel.update_attributes(:user_id => params[:channel][:moderator_id]) if params[:channel][:moderator_id].present?

    if params['members'].present?
      params['members']+= ",#{current_user.id}" unless params[:unsubscribe]
      #deleting all the previously stored members
      @channel.subscriptions.delete_all
      #adding members to CUG
      params['members'].split(',').each do |member|
        Subscription.create(:channel_id => @channel.id, :user_id => member, :is_core => true)
      end
    end

    subscription = @channel.subscriptions.where(:user_id => current_user.id).first
    if subscription.present?
      subscription.update_attributes(:is_core => params[:subscription][:is_core])
    end
  end

  #change the views
  def get_cug_view
    @channels = []
    @beehive_view = BeehiveView.where(:id => params[:cug_view_type]).first
    if @beehive_view.has_children?
      @beehive_view.children.each do |children|
        cugs = current_user.get_cugs_unsync_count(current_user.send(children.view_scope, params[:cug_name]), params[:hide_insync_cugs] || @beehive_view.show_insync)
        @channels << {:beehive_view_name => children.view_name, :beehive_view_id => children.id, :beehive_view_for => children.view_for, :channels => cugs,:keyword=>params[:cug_name]}
      end
    elsif @beehive_view.ancestry?
      @beehive_view.root.children.each do |children|
        cugs = current_user.get_cugs_unsync_count(current_user.send(children.view_scope, params[:cug_name]), params[:hide_insync_cugs])
        @selected_beehive_view_cugs = {:channels => cugs} if children.id == @beehive_view.id
        @channels << {:beehive_view_name => children.view_name, :beehive_view_id => children.id, :beehive_view_for => children.view_for, :channels => cugs,:keyword=>params[:cug_name]}
      end
    else
      cugs = current_user.get_cugs_unsync_count(current_user.send(@beehive_view.view_scope, params[:cug_name]), params[:hide_insync_cugs])
      @channels << {:beehive_view_name => @beehive_view.view_name, :beehive_view_id => @beehive_view.id, :beehive_view_for => @beehive_view.view_for, :channels => cugs,:keyword=>params[:cug_name]}
    end
    @buzz = Buzz.new{|b| b.buzz_names.build}
  end


  #getting cug stats
  def show
    @channel = Channel.where(:id => params[:id]).first
  end

  #fetching user CUG's aliases and names
  def cugs_names_with_aliases
    channels = Channel.includes(:channel_aliases, :subscriptions => :user).searched_channels(true, params[:query], current_user.id)
    render :json => { :query => params[:query],
      :suggestions => channels.blank? ? ["No CUGs Found"] : channels.map{|channel| "#{ChannelAlias.select("name,id").where(:user_id => current_user.id, :channel_id => channel.id).first.try(:name) || channel.name}"},
      :data => channels.blank? ? [0] : channels.map{|channel| channel.id} }
  end

  def advance_search
    @subscribed_channels_tag_list = current_user.subscribed_channels_tag_list.uniq!
    @subscribed_channels_subscribed_user_list = current_user.subscribed_channels_subscribed_user_list
    @flags = Flag.all
    @insync_type = [{:name => 'Insync', :val => true}, {:name => 'Out of sync', :val => false}]
  end

  def buzz_properties
    @channel = params[:channel_id].to_i == 0 ? Channel.where(:name => params[:channel_name]).first : Channel.find(params[:channel_id])
    if @channel
      @buzz= Buzz.new
      @flags = Flag.custom_flags
      @cug_tags = @channel.tags.order('name asc').collect {|t| [t.name, t.id]}
      @user_names = @channel.subscribed_users.delete_if{|user| user.id == current_user.id}
    else
      flash.now[:error] = "Channel or CUG doesn't exit, please select appropriate one."
    end
  end
end