class PriorityBuzzsController < ApplicationController

  def new
    @buzz = Buzz.find(params[:buzz_id])
    @user_names = @buzz.buzz_members.present? ? @buzz.buzz_members_details.delete_if{|user| user.id == current_user.id} : @buzz.channel.subscribed_users.where("users.id != #{current_user.id}").order("users.first_name asc")
    @user_names.each do |user|
      unless @buzz.priority_buzzs.pluck(:user_id).include?(user.id)
        @buzz.priority_buzzs.build(:user_id => user.id)
      end
    end
  end

  def create
    @buzz = Buzz.find_by_id(params[:buzz_id])
    pb = PriorityBuzz.where(:buzz_id => @buzz.id).first
    @buzz.update_attributes(params[:buzz])
    flash.now[:notice] = pb.blank? ? "Selected user(s) successfully added to the priority list for being InSync with this buzz" : "Successfully updated the priority list of user(s)."
  end

end
