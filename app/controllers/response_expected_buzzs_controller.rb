class ResponseExpectedBuzzsController < ApplicationController\

    def new
    @buzz = Buzz.find(params[:buzz_id])
    @user_names = @buzz.buzz_members.present? ? @buzz.buzz_members_details.delete_if{|user| user.id == current_user.id} : @buzz.channel.subscribed_users.where("users.id != #{current_user.id}")
    @user_names.each do |user|
      unless @buzz.response_expected_buzzs.pluck(:user_id).include?(user.id)
        @buzz.response_expected_buzzs.build(:user_id => user.id)
      end
    end
  end

  def create
    @buzz = Buzz.find_by_id(params[:buzz_id])
    re = ResponseExpectedBuzz.where(:buzz_id => @buzz.id).first
    @buzz.update_attributes(params[:buzz])
    if @buzz.errors.blank?
      flash.now[:notice] = re.blank? ? "Successfully added user(s) to Response Expected list and the CUG will appear in their Action View." : "Successfully updated the user(s) under the Response Expected list"
    else
      msg = []
      flash.now[:error] = @buzz.errors.full_messages.each{|e| msg << "#{e}" unless msg.include?(e)}
    end
  end

end