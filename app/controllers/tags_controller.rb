class TagsController < ApplicationController

  #Adding a tag to channel
  def create
    @buzz = Buzz.where(:id => params[:buzz_id]).first
    @channel = @buzz.channel
    if params[:tag]
      tags, @msg = Tag.add_buzz_tag(@channel, params[:tag])
      BuzzTag.add_buzz_tag(@buzz, tags) if tags.present?
    end
    @cug_tags = @channel.tags.order("name asc").collect {|t| [t.name, t.id]}
    respond_to do |format|
      format.js {render :template => 'buzz_tags/buzz_tag_list.js.erb'}
    end
  end

  def channel_tag
    channel = Channel.find(params[:channel_id])
    tags, @msg = Tag.add_buzz_tag(channel, params[:tag])
    @cug_tags = channel.tags.order("name asc").collect {|t| [t.name, t.id]} if @msg.blank?
  end
  
end