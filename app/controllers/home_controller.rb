require 'beehive_command'

class HomeController < ApplicationController
  layout "dashboard"

  def help
    render :layout => 'admin'
  end

  #downloading attachment
  def download_attachment
    buzz = Buzz.find(params[:id])
    send_file buzz.attachment.current_path, :type => buzz.attachment.set_content_type
  end

  def beehive_search
    #    search_count = 0
    @search_data = Channel.advance_search_in_channel_buzzes(params, current_user, 1)
    #    @search_data.map{|c|@search_count += c[:buzz_count]}
    #    flash.now[:notice] = "#{@search_count} #{@search_count == 1 ? 'record' : 'records'} found"
    respond_to do |format|
      format.js
    end
  end

  def beehive_search_more
    params_data = {}
    params_data[:beehive_search] = params[:beehive_search]
    params_data[:beehive_search][:current_cug_id] = params[:channel_id]
    @search_data = Channel.advance_search_in_channel_buzzes(params_data.symbolize_keys!, current_user, params['next_page'])
    respond_to do |format|
      format.js
    end
  end


end
