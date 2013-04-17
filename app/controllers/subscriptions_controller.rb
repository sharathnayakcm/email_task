class SubscriptionsController < ApplicationController

  #Adding subscription to a channel
  def create
    @channel = Channel.find params[:id]
    subscription = Subscription.new(:channel_id => @channel.id, :user_id => current_user.id, :is_core => @channel.is_cug ? true : false)
    if subscription.save
      flash.now[:notice] = "You have been subscribed successfully to #{@channel.channel_or_cug}  #{@channel.name}"
    else
      msg = []
      flash.now[:error] = subscription.errors.full_messages.each{|e| msg << "#{e}" unless msg.include?(e)}
    end
  end
  
end
