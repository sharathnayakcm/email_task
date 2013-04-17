class BuzzTasksController < ApplicationController
  before_filter :get_buzz_or_channel

  def update
    before_update = @buzz_task_obj.buzz_tasks.map(&:attributes).to_set
    unless @buzz_task_obj.update_attributes(params[@buzz_task_obj.class.to_s.downcase.to_sym])
      @success = false
      @buzz_tasks = @buzz_task_obj.buzz_tasks
    else
      if params[:channel_id].present?
        @channel = Channel.find(params[:channel_id])
        @channel_buzz_tasks = @channel.buzz_tasks.where(:user_id => current_user.id)
      end
      flash.now[:notice] = 'Sucessfully saved'
      after_update = @buzz_task_obj.buzz_tasks.map(&:attributes).to_set
      compare_change = before_update == after_update
      @success = true
      flash.now[:notice] = "Dozz has been successfully sent to #{current_user.dozz_email ? current_user.dozz_email : current_user.email}" if compare_change == false
    end
  end

  #Destroy a task of a buzz
  def destroy
    BuzzTask.find(params[:buzz_task_id]).destroy
    @message = 'Dozz successfully deleted '
    respond_to do |format|
      format.js { render :template => 'buzz_tasks/update_buzz_task_list.js.erb'}
    end
  end

  #Making a task complete
  def buzz_task_mark_as_complete
    BuzzTask.find(params[:buzz_task_id]).update_attributes(:status => true)
    @message = 'Dozz successfully marked as completed'
    respond_to do |format|
      format.js { render :template => 'buzz_tasks/update_buzz_task_list.js.erb'}
    end
  end

  protected 
  def get_buzz_or_channel
    if params[:is_channel]
      @channel = Channel.find(params[:channel_id])
      @buzz_task_obj = @channel
    else
      @buzz = Buzz.find(params[:buzz_id])
      @buzz_task_obj = @buzz
    end
    @buzz_tasks = @buzz_task_obj.buzz_tasks.where(:user_id => current_user.id)
  end
end
