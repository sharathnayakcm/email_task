class FavouritesController < ApplicationController

  #adding a Channel/CUG to fav list
  def create
    @fav_channel = current_user.watch_channels.new(:channel_id => params[:channel_id])
    if @fav_channel.save
      flash.now[:notice] = "#{@fav_channel.channel.channel_or_cug} #{@fav_channel.channel.name} has been added successfully to your favorite list"
    else
      flash.now[:error] = @fav_channel.errors.full_messages
    end
  end

  #removing a Channel/CUG from fav list
  def destroy
    @fav_channel = WatchChannel.find(params[:id])
    @fav_channel.delete
    flash.now[:notice] = "#{@fav_channel.channel.channel_or_cug} #{@fav_channel.channel.name} has been removed from your favorite list"
  end
  
end
