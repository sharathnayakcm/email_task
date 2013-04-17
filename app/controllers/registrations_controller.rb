class RegistrationsController < Devise::RegistrationsController

  layout false
  
  #updating user details
  def edit
    @user = current_user
    respond_to do |format|
      format.js
      format.html { redirect_to channels_path}
    end
  end

  def update
    if current_user.update_attributes(params[:user])
      sign_in current_user, :bypass => true
      flash.now[:notice] = 'Profile saved successfully.'
      @valid = true
    else
      msg = []
      flash.now[:error] = current_user.errors.full_messages.each{|e| msg << "#{e}" unless msg.include?(e)}
    end
  end
end