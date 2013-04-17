include ActionView::Helpers::DateHelper
include ActionView::Helpers::TextHelper

class Api::RezzsController < Api::BaseController
  
  def create
    resource = User.find_for_database_authentication(:email=>params[:user][:email], :authentication_token => params[:user][:auth_token])
    if !resource.nil?
      #buzz = Buzz.find_by_id(params[:buzz_id])
      buzz = Buzz.find(params[:buzz_id])
      command = buzz.generate_rezz_command(params[:message])
      process_result = process_command_task(command)
      render :json=> {:success=>true, :process_result => process_result,:channel_id => buzz.channel_id , :buzz_id => params[:buzz_id], :message => process_result[:process_msg][:msg],:buzz => buzz.message, :by =>  buzz.user_id == resource.id ? 'You' : buzz.buzzed_user_fullname, :created => time_ago_in_words(buzz.created_at).to_s}
    else
      render :json=> {:success=>false, :message=>"Unauthorized access", :channel_id => params[:channel_id], :buzz_members => members, :members => channel_members}, :status=>401
    end
  end

  def view
    resource = User.find_for_database_authentication(:email=>params[:user][:email], :authentication_token => params[:user][:auth_token])
    if !resource.nil?
      #buzz = Buzz.find_by_id(params[:buzz_id])
      buzz = Buzz.find(params[:buzz_id])
      channel = buzz.channel
      render :json=> {:success=>true, :rezzs => channel.buzz_data(buzz.children, resource, channel.is_cug), :buzz_id => params[:buzz_id]}
    else
      render :json=> {:success=>false, :message=>"Unauthorized access", :channel_id => params[:channel_id], :buzz_members => members, :members => channel_members}, :status=>401
    end
  end


end