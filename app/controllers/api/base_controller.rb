# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'beehive_command'

class Api::BaseController < ApplicationController
  prepend_before_filter :require_no_authentication, :only => [:create ]
  #include Devise::Controllers::InternalHelpers
  include BeehiveCommand

  before_filter :ensure_params_exist

  respond_to :json


  protected
  def ensure_params_exist
    return unless params[:user].blank?
    render :json=>{:success=>false, :message=>"missing user_login parameter"}, :status=>422
  end

  def invalid_login_attempt
    warden.custom_failure!
    render :json=> {:success=>false, :message=>"Invalid email or password"}, :status=>401
  end
end
