class RezzsController < ApplicationController
  before_filter :find_buzz

  #creating rezz object
  def index
    @rezzs = @buzz.root.subtree
  end

  def new
    @rezzs = @buzz.root.subtree
    @user_names =  (@buzz.buzz_members.blank? ? (@buzz.channel.subscribed_users) : (@buzz.buzz_members_details)).delete_if{|user| user.id == current_user.id}
    respond_to do |format|
      format.js
      format.html { redirect_to channels_path}
    end
  end
  
  #create rezz 
  def create
    channel = @buzz.channel
    @rezz = @buzz.children.new(params[:rezz])
    if @rezz.save
      save_users(@rezz, params)
      response_buzz = ResponseExpectedBuzz.response_expected(@buzz.id,current_user.id).first
      response_buzz.delete if response_buzz
      #limit the rezz if buzz is limited
      @rezz.save_rezz_members(@buzz)
      #used to set the buzz_name to the rezz
      @rezz.set_rezz_name(current_user)
      flash.now[:notice] = "Rezzed out to #{channel.channel_or_cug} #{channel.name} successfully"
    else
      msg = []
      flash.now[:error] = @rezz.errors.full_messages.each{|e| msg << "#{e}" unless msg.include?(e)}
    end
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

  end



  #destroying the rezz
  def destroy
    @rezz = @buzz.root.subtree.find(params[:id])
  end

  def members
    if params[:user_id]
      render :text => @buzz.buzzed_users.include?(params[:user_id].to_i)
    else
      render :text => @buzz.rezzed_users.size == 0
    end
  end

  private
  def find_buzz
    @buzz = Buzz.where("id = ?", params[:buzz_id]).first
  end
end
