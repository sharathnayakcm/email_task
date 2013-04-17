class BuzzFlagsController < ApplicationController
  before_filter :get_buzz

  #Getting all the flags
  def index
    @flags = Flag.custom_flags
  end

  #Adding flags to a buzz by a particular user
  def create
    #Destroying all the previously stored flag of a buzz by a particular user
    BuzzFlag.destroy_all(:buzz_id => params[:buzz_id], :user_id => current_user.id)
    params[:buzz_flag].values.each do |buzz_flag_attr|
      @buzz.buzz_flags.create(buzz_flag_attr.merge(:user_id => current_user.id)) if buzz_flag_attr.include?(:flag_id)
    end unless params[:buzz_flag].nil?
  end

  private
  def get_buzz
    @buzz = Buzz.find(params[:buzz_id])
  end
end