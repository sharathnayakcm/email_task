class ChannelsController < ApplicationController
  layout 'dashboard'
  before_filter :load_channel, :only => [:show, :edit]
  
  def new
    @channel = current_user.channels.new{|c| c.buzzs.build}
  end

  #creating a new channel
  def create
    @channel = current_user.channels.new(params[:channel])
    if @channel.save
      Subscription.create(:channel_id => @channel.id, :user_id => current_user.id, :is_core => true)
      @channel.save_cug_members(params['members']) if params['members'].present?
      flash.now[:notice] = "#{@channel.channel_or_cug} #{@channel.name} added successfully"
    else
      msg = []
      flash.now[:error] = @channel.errors.full_messages.each{|e| msg << "#{e}" unless msg.include?(e)}
    end
  end
  
  #getting all the channels
  def get_channels
    @channels = []
    @beehive_view = BeehiveView.find(params[:channel_view_type])
    if @beehive_view.has_children?
      @beehive_view.children.each do |children|
        channels = current_user.get_channels_unsync_count(current_user.send(children.view_scope, params[:channel_name]))
        @channels << {:beehive_view_name => children.view_name, :beehive_view_id => children.id, :beehive_view_for => children.view_for, :channels => channels, :keyword => params[:channel_name]}
      end
    elsif @beehive_view.ancestry?
      @beehive_view.root.children.each do |children|
        channels = current_user.get_channels_unsync_count(current_user.send(children.view_scope, params[:channel_name]))
        @selected_beehive_view_channels = {:channels => channels} if children.id == @beehive_view.id
        @channels << {:beehive_view_name => children.view_name, :beehive_view_id => children.id, :beehive_view_for => children.view_for, :channels => channels, :keyword => params[:channel_name]}
      end
    else
      channels = current_user.get_channels_unsync_count(current_user.send(@beehive_view.view_scope, params[:channel_name]))
      @channels << {:beehive_view_name => @beehive_view.view_name, :beehive_view_id => @beehive_view.id, :beehive_view_for => @beehive_view.view_for, :channels => channels, :keyword => params[:channel_name]}
    end
  end

  def edit
    @channel_aliases = [ @channel.channel_aliases.find_or_initialize_by_user_id(current_user.id) ]
    @fav_channel = [ @channel.watch_channels.find_or_initialize_by_user_id(current_user.id) ]
    @subscription = @channel.subscriptions.includes(:user).where(:user_id => current_user.id).first
    respond_to do |format|
      format.js
      format.html { redirect_to channels_path}
    end
  end

  #updating a new channel
  def update
    @subscription_deleted = false
    @channel = Channel.includes([:subscriptions, :channel_aliases]).find(params[:id])
    if @channel.update_attributes(params[:channel])
      @channel.unsubscribe_self(current_user) if params[:unsubscribe]
      flash.now[:notice] = 'Sucessfully updated'
    else
      msg = []
      flash.now[:error] = @channel.errors.full_messages.each{|e| msg << "#{e}" unless msg.include?(e)}
    end
  end

  private
  def load_channel
    @channel = Channel.find(params[:id])
  end 
end
