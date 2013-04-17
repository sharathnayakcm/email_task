class BuzzNamesController < ApplicationController
  before_filter :get_buzz, :except => :edit

  # Getting buzz name for the buzz by the current user
  def new
    @buzz_name = BuzzName.new
  end

  def edit
    @buzz = Buzz.where(:id => params[:id]).includes('user').first
    @buzz_name = @buzz.buzz_names.where('user_id = ?', current_user.id).first
  end

  # Creating a new buzz name for the parent buzz and its children(if the parent buzz have any.)
  def create
    @buzz_name = BuzzName.create_all_buzz_name(@buzz, current_user.id, params[:buzz_name][:name])
    if @buzz_name.valid?
      flash.now[:notice] = 'Buzz Name assigned successfully.'
    else
      msg = []
      flash.now[:error] = @buzz_name.errors.full_messages.each{|e| msg << "#{e}" unless msg.include?(e)}
    end
    respond_to do |format|
      format.js { render :template => 'buzz_names/update.js.erb'}
    end
  end

  # Updating buzz name for the buzz by the current user
  def update
    @buzz_name = BuzzName.update_all_buzz_name(@buzz, current_user.id, params[:buzz_name][:name])
    if @buzz_name.valid?
      flash.now[:notice] = 'Buzz Name updated successfully.'
    else
      msg = []
      flash.now[:error] = @buzz_name.errors.full_messages.each{|e| msg << "#{e}" unless msg.include?(e)}
    end
    respond_to do |format|
      format.js { render :template => 'buzz_names/update.js.erb'}
    end
  end

  # Deleting buzz name for the buzz by the current user
  def destroy
    BuzzName.delete_buzz_name(@buzz, current_user)
  end

  protected
  
  def get_buzz
    @buzz = Buzz.where(:id => params[:buzz_id]).includes('user').first
  end
end