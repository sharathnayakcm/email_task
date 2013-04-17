# To change this template, choose Tools | Templates
# and open the template in the editor.

include ActionView::Helpers::DateHelper
include ActionView::Helpers::TextHelper

class Api::BuzzesController < Api::BaseController

  before_filter :get_resource,:only => [:dozz_detail,:task_detail,:save_task,:complete_or_delete_dozz_task,:buzz_flags,:save_buzz_flags]

  def insync_buzz
    resource = User.find_for_database_authentication(:email=>params[:user][:email], :authentication_token => params[:user][:auth_token])
    if !resource.nil?
      render :json=> {:success=>true, :message => api_command_message(BuzzInsync.insync(params[:channel_id], params[:buzz_id], resource)), :channel_id => params[:channel_id]}
    else
      render :json=> {:success=>false, :message=>"Unauthorized access", :channel_id => params[:channel_id]}, :status=>401
    end
  end

  def limit_user
    resource = User.find_for_database_authentication(:email=>params[:user][:email], :authentication_token => params[:user][:auth_token])
    if !resource.nil?
      buzz = Buzz.find(params[:id])
      limit_users = params[:members].scan(/\d+/) || []
      channel_members = buzz.channel.channel_members.collect{|u| {:id => u.id, :display_name => u.display_name}}
      channel_members.delete({:id => resource.id, :display_name => resource.display_name})
      present = true
      buzz.rezzed_users.each do |u|
        if !limit_users.include?(u.to_s)
          present = false
          break
        end
      end
      unselected_users = buzz.rezzed_users - limit_users
      if present == false
        render :json=> {:success=>false, :channel_id => buzz.channel_id, :members => channel_members,:buzz_members => buzz.buzz_members.collect{|bm| bm.user_id}, :id => params[:id], :buzz => buzz.message, :by =>  buzz.user_id == resource.id ? 'You' : buzz.buzzed_user_fullname, :created => time_ago_in_words(buzz.created_at).to_s , :message=>"Some of the buzzer(s) have rezzed on this Buzz. Hence #{channel_members.select{|cm| unselected_users.include?(cm[:id].to_i)}.map{|u| u[:display_name]}} have to be a part of limited users."}
      else
        render :json=> {:success=>true, :channel_id => buzz.channel_id, :members => buzz.buzz_members.collect{|bm| bm.user_id}, :id => params[:id], :buzz => buzz.message, :by =>  buzz.user_id == resource.id ? 'You' : buzz.buzzed_user_fullname, :created => time_ago_in_words(buzz.created_at).to_s , :message=>  BuzzMember.limit_members(buzz, limit_users)}
      end
    else
      render :json=> {:success=>false, :message=>"Unauthorized access", :channel_id => buzz.channel_id, :members => buzz.buzz_members.collect{|bm| bm.user_id}, :id => params[:id], :buzz => buzz.message, :by =>  buzz.user_id == resource.id ? 'You' : buzz.buzzed_user_fullname, :created => time_ago_in_words(buzz.created_at).to_s}, :status=>401
    end
  end

  def members
    resource = User.find_for_database_authentication(:email=>params[:user][:email], :authentication_token => params[:user][:auth_token])
    if !resource.nil?
      buzz = Buzz.find(params[:id])
      channel_members = buzz.channel.channel_members.collect{|u| {:id => u.id, :display_name => u.display_name}}
      channel_members.delete({:id => resource.id, :display_name => resource.display_name})
      render :json=> {:success=>true, :channel_id => buzz.channel_id, :buzz_members => buzz.buzz_members.collect{|u| {:id => u.user_id,:display_name => u.user.display_name}}, :members => channel_members}
    else
      render :json=> {:success=>false, :message=>"Unauthorized access", :channel_id => params[:channel_id], :buzz_members => members, :members => channel_members}, :status=>401
    end
  end

  def buzz_detail
    resource = User.find_for_database_authentication(:email=>params[:user][:email], :authentication_token => params[:user][:auth_token])
    if !resource.nil?
      buzz = Buzz.find(params[:id])
      if !buzz.nil?
        is_insynced = true
        if buzz.channel.is_cug
          buzz_insync = BuzzInsync.where(:channel_id => buzz.channel_id, :user_id => resource.id).first
          insync_buzz_id = buzz_insync.nil? ? 0 : buzz_insync.buzz_id
          is_insynced = buzz.user_id != resource.id ? (buzz.id <= insync_buzz_id) : true
        end
        data = {
          :id => buzz.id,
          :message => buzz.message,
          :buzzed_by => buzz.user_id == resource.id ? 'You' : buzz.buzzed_user_fullname,
          :created_at => time_ago_in_words(buzz.created_at).to_s + ' ago',
          :name => buzz.channel.name, :channel_id => buzz.channel_id,
          :is_cug => buzz.channel.is_cug,
          :insynced => is_insynced,
          :priority => buzz.priority,
          :attachment_path => buzz.attachment.current_path,
          :attachment_type => (buzz.attachment.blank? ? "" : buzz.attachment.set_content_type),
          :attachment_url => buzz.attachment.url,
          :rezz_count => buzz.root.subtree.count,
          :childless => buzz.is_childless?,
          :descendants => buzz.has_descendents_or_parent?,
          :rezz => buzz.ancestry ? true :false,
          :limit_user_ids => buzz.buzz_members.any? ? buzz.buzz_members.collect{|bm| bm.user_id} : [],
          :limit_user_names => buzz.get_buzz_member_names,
          :is_limited => buzz.buzz_members.any?,
          :limit_users => buzz.buzz_members.any? ? buzz.buzz_members.collect{|bm| [bm.user_id, bm.user.display_name]} : [],
          :buzzed_by_id => buzz.user_id,
          :parent_id => buzz.parent_id,
          :channel_owner => buzz.channel.moderator?(resource),
          :root_id => buzz.root_id,
          :channel_id => buzz.channel_id,
          :buzz_tags => buzz.tags.blank? ? "No Tag": buzz.tags.collect{|t| t.name}.join(', '),
          :buzzers => buzz.channel.buzzers,
          :active_buzzers => buzz.channel.active_buzzers
        }
        #buzz.channel.set_last_viewed(@resource)
        render :json=> {:success=>true, :data => data,:id => params[:id]}
      end
    else
      render :json=> {:success=>false, :message=>"Unauthorized access", :id => params[:id]}, :status=>401
    end
  end

   def get_cug_tags
    resource = User.find_for_database_authentication(:email=>params[:user][:email], :authentication_token => params[:user][:auth_token])
    if !resource.nil?
      #buzz = Buzz.find_by_id(params[:buzz_id])
      buzz = Buzz.find(params[:buzz_id])
      buzztags = buzz.buzz_tags.map{|i| i.tag_id}
      channel_tags = buzz.channel.tags.uniq
      render :json=> {:success=>true, :cug_tags=> channel_tags,:buzz_tags=>buzztags,:channel_id => params[:channel_id]}
    else
      render :json=> {:success=>false, :message=>"Unauthorized access", :channel_id => params[:channel_id]}, :status=>401
    end
  end

  def add_new_tag
    resource = User.find_for_database_authentication(:email=>params[:user][:email], :authentication_token => params[:user][:auth_token])
    if !resource.nil?
      #buzz = Buzz.find_by_id(params[:buzz_id])
      buzz = Buzz.find(params[:buzz_id])
      channel = buzz.channel
      tags,msg = Tag.add_buzz_tag(channel,params[:tag])
      unless tags.empty?
        BuzzTag.add_buzz_tag(buzz,tags[0])
        render :json=> {:success=>true, :tags=> tags,:channel_id => params[:channel_id],:buzz_id=>params[:buzz_id]}
      else
        render :json=> {:success=>false, :message=>msg, :channel_id => params[:channel_id],:buzz_id=>params[:buzz_id]}
      end
    else
      render :json=> {:success=>false, :message=>"Unauthorized access", :channel_id => params[:channel_id]}, :status=>401

    end
  end

  def save_buzz_tags
    arr = JSON::parse(params[:buzz_tag])
    resource = User.find_for_database_authentication(:email=>params[:user][:email], :authentication_token => params[:user][:auth_token])
    if !resource.nil?
      #buzz = Buzz.find_by_id(params[:buzz_id])
      buzz = Buzz.find(params[:buzz_id])
      buzz.buzz_tags.delete_all
      tag_name = params[:buzz_tag].scan(/([[:alnum:]]+)-new/).flatten || []
      matches = arr.grep /.*-new/
      btags = arr.delete_if{|v| matches.include? v}
      if tag_name != []
        tag_name.each do |t|
          tags,msg = Tag.add_buzz_tag(buzz.channel,t)
          btags << tags
        end
       btags= btags.flatten
      end
      BuzzTag.save_buzz_tags(buzz,btags)
      render :json=> {:success=>true,:channel_id => params[:channel_id],:buzz_id=>params[:buzz_id]}
    else
      render :json=> {:success=>false, :message=>"Unauthorized access", :channel_id => params[:channel_id]}, :status=>401
    end

    
  end

  def dozz_detail
    if !@resource.nil?
      buzz = Buzz.find(params[:id])
      completed_tasks = buzz.buzz_tasks.completed_dozzes
      if params[:status] == "true"
        tasks = completed_tasks + buzz.buzz_tasks
      else
        tasks = buzz.buzz_tasks
      end
      render :json => {:success => true, :tasks => tasks,:id => params[:id],:completed_dozz => (completed_tasks.nil? ? 0 : completed_tasks.size)}
    else
      render :json=> {:success=> false, :message=>"Unauthorized access", :id => params[:id]}, :status=>401
    end
  end

  def task_detail
    if !@resource.nil?
      render :json => {:success => true, :task => BuzzTask.find(params[:id]), :id => params[:id]}
    else
      render :json=> {:success=> false, :message=>"Unauthorized access", :id => params[:id]}, :status=>401
    end
  end

  def complete_or_delete_dozz_task
    if !@resource.nil?
      params[:act] == "Complete" ? BuzzTask.find(params[:id]).update_attributes(:status => true) : BuzzTask.find(params[:id]).destroy
      render :json => {:success => true, :message => "Successfully #{task_status(params[:act])}", :id => params[:id],:buzz_id => params[:buzz_id] }
    else
      render :json=> {:success=> false, :message=>"Unauthorized access", :id => params[:id]}, :status=>401
    end
  end

  def save_task
    if !@resource.nil?
      buzz = Buzz.find(params[:buzz_task][:buzz_id])
      if params[:id].nil? or params[:id] == ""
        buzz.buzz_tasks.create(params[:buzz_task])
      else
        buzz.buzz_tasks.find(params[:id]).update_attributes(params[:buzz_task])
      end
      render :json => {:success => true, :message => "Task has been updated successfuly", :id => params[:id] || '',:buzz_id => params[:buzz_id] }
    else
      render :json=> {:success=> false, :message=>"Unauthorized access", :id => params[:id]}, :status=>401
    end
  end

  def buzz_flags
    if !@resource.nil?
      render :json=> {:success=>true, :buzz_flags => BuzzFlag.where("buzz_id=? and user_id =?",params[:id], @resource.id), :flags => Flag.all_flags(params[:id], @resource)}
    else
      render :json=> {:success=>false, :message=>"Unauthorized access", :channel_id => params[:channel_id]}, :status=>401
    end
  end

  def save_buzz_flags
    if !@resource.nil?
      buzz_flags = JSON.parse(params[:buzz_flag]).map { |b| b[1] }
      BuzzFlag.save_buzz_flags(params[:buzz_id], @resource, buzz_flags)
      render :json=> {:success=>true, :channel_id => params[:channel_id], :buzz_id => params[:buzz_id], :message=>"Buzz Flag have been saved successfully"}
    else
      render :json=> {:success=>true, :channel_id => params[:channel_id], :buzz_id => params[:buzz_id], :message=>"Unauthorized access"}, :status=>401
    end
  end

  private

  def get_resource
    @resource = User.find_for_database_authentication(:email=>params[:user][:email], :authentication_token => params[:user][:auth_token])
  end

  def task_status(act)
    act == "Complete"  ? " marked Dozz as complete " : " deleted the Dozz"
  end


end