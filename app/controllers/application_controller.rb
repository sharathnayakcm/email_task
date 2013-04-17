class ApplicationController < ActionController::Base
  require 'will_paginate/array'
  protect_from_forgery
  before_filter :authenticate_user!
  has_mobile_fu false

  #rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  private
  def record_not_found
    flash[:notice] = 'Sorry, something went wrong. Please contact Beehive Support team.'
    if request.xhr?
      render 'shared/rescue_template.js'
    else
      redirect_to :back
    end
  end
  
  def stored_location_for(resource_or_scope)
    nil
  end
end