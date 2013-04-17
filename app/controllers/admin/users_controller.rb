class Admin::UsersController < ApplicationController
  
  before_filter :check_domain
  before_filter :load_user, :only => [:edit, :update, :deactivate, :activate]

  layout 'admin'
  
  #getting all the users
  def index
    @users = User.paginate(:page => params[:page], :per_page => 10)
  end

  def new
    @user = User.new
  end

  #creating a new user
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "#{@user.full_name} invited successfully"
      redirect_to admin_users_path
    else
      msg = []
      flash[:error] = @user.errors.full_messages.each{|e| msg << "#{e}" unless msg.include?(e)}
      render 'new'
    end
  end

  #updating a new user
  def update
    if @user.update_attributes(params[:user])
      flash[:notice] = 'User details updated successfully'
      redirect_to admin_users_path
    else
      msg = []    
      flash[:error] = @user.errors.full_messages.each{|e| msg << "#{e}" unless msg.include?(e)}
      render 'edit'
    end
  end

  #Saving users through the CSV file
  def save_csv
    if params[:upload_csv].blank?
      flash[:error] = 'Please upload file'
    else
      errors = User.upload_csv(params[:upload_csv][:csv])
      errors.blank? ? (flash[:notice] = 'New users invited successfully') : flash[:error] = errors
    end
    redirect_to admin_users_path
  end

  #deactivating user
  def deactivate
    if @user.deactivate
      flash[:notice] = "#{@user.full_name} deactivated successfully"
    else
      flash[:error] = 'Exeception occur'
    end
    redirect_to admin_users_path
  end

  #activating user
  def activate
    if @user.activate
      flash[:notice] = "#{@user.full_name} activated successfully"
    else
      flash[:error] = 'Exeception occur'
    end
    redirect_to admin_users_path
  end

  private

  def load_user
    @user = User.find params[:id]
  end
  
  def check_admin
    redirect_to root_path unless current_user.is_admin?
  end

  def check_domain
    unless (s = Setting.first) && s.domain_name.present?
      flash[:notice] = 'Please set the domain name first'
      redirect_to admin_users_path
    end
  end
end