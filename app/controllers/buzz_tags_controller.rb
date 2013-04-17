class BuzzTagsController < ApplicationController
  before_filter :get_channel_and_buzz

  def index
    #getting all the tags associated to the CUG and adding "Add new" to array 
    @cug_tags = @channel.tags.order('name asc').collect {|t| [t.name, t.id]}
    respond_to do |format|
      format.js {render :template => 'buzz_tags/buzz_tag_list.js.erb'}
    end
  end
  
  #adding new tag to a buzz
  def create
    if params[:buzz_tag].present?
      tag = Tag.where(:id => params[:buzz_tag]).first
      @buzz_tag = BuzzTag.add_buzz_tag(@buzz, tag.id)
    end
  end

  #deleting a tag for a buzz
  def destroy
    BuzzTag.where(:buzz_id => params[:buzz_id], :tag_id => params[:tag_id]).first.destroy
  end

  private
  def get_channel_and_buzz
    @channel = Channel.where(:id => params[:channel_id]).first
    @buzz = @channel.buzzs.where(:id => params[:buzz_id]).first
  end
end
