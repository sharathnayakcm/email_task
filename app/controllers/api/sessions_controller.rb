class Api::SessionsController < Api::BaseController

  def create
    build_resource
    resource = User.find_for_database_authentication(:email=> params[:user][:email])
    
    return invalid_login_attempt unless resource

    if resource.valid_password?(params[:user][:password])
      sign_in("user", resource)
      render :json=> {:success=>true, :auth_token=>resource.authentication_token, :user_id => resource.id, :email=>resource.email, :default_view => resource.user_preference.default_view.to_s, :start_days_ago => APP_CONFIG['date']['start_days_ago'].to_s, :max_calendar_days_diff => APP_CONFIG['date']['max_calendar_days_diff'].to_s}
      return
    end
    invalid_login_attempt
  end

  def destroy
    sign_out(resource_name)
  end

  def forgot_password
    build_resource
    #resource = User.find_for_database_authentication(:email=>params[:user][:email])

    resource = resource_class.send_reset_password_instructions(params[:user])

    if successfully_sent?(resource)
      render :json=> {:success=>true, :message=>"A email with reset password link has been sent to your email"}
      return
    else
      render :json=> {:success=>false, :message=>"Invalid email", :status=>401}
    end
  end

  def change_password
    #build_resource
    resource = User.find_for_database_authentication(:email=>params[:user][:email], :authentication_token => params[:auth_token])

    if !resource.nil? && resource.update_with_password(params[:user])
      sign_in("user", resource)
      render :json=> {:success=>true, :message=>"Your password has been changed successfully"}
      return
    else
      render :json=> {:success=>false, :message=>api_command_message(resource.errors.full_messages), :status=>401}
    end
  end

  def preference
    resource = User.find_for_database_authentication(:email=>params[:user][:email], :authentication_token => params[:user][:auth_token])
    if !resource.nil?
      render :json=> {:success=>true, :preference => resource.user_preference, :type => 'list', :user => resource}
      return
    elsif resource.nil?
      render :json=> {:success=>false, :message=>"Unauthorized access", :type => 'list', :status=>401}
    else
      render :json=> {:success=>false, :message=>api_command_message(resource.errors.full_messages), :type => 'list', :status=>401}
    end
  end

  def save_preference
    resource = User.find_for_database_authentication(:email=>params[:user][:email], :authentication_token => params[:user][:auth_token])
    if !resource.nil?
      params[:user].delete(:auth_token)
      if resource.update_attributes(params[:user]) && resource.user_preference.update_attributes(params[:preference])
        render :json=> {:success=>true, :message=>"User details have been updated successfully", :user => resource, :preference => resource.user_preference, :type => 'save'}
      else
        render :json=> {:success=>false, :message=> api_command_message(resource.errors.full_messages + resource.user_preference.errors.full_messages), :user => resource, :preference => resource.user_preference, :type => 'save'}
      end
    else
      render :json=> {:success=>false, :message=>"Unauthorized access", :type => 'save', :status=>401}
    end
  end
end