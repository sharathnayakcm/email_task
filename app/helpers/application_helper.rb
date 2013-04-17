module ApplicationHelper

  #showing flash message
  def show_flash_message
    message = ''
    flash.each do |type, msg|
      if msg.is_a?(Array)
        msg.each{|m| message << "<span class='#{type}'>#{m}</span>"}
      else
        message << "<span class='#{type}'>#{msg}</span>"
      end
    end
    message.html_safe
  end

  #using for displaying of buzz
  def buzz_with_linebreak(msg)
    Rinku.auto_link(msg, :all, 'target="_blank"')
  end

  def attachment_file_name(url)
    truncate(File.basename(url), :length => 50, :omission => '...') if url
  end

  def check_if_user_is_member(buzz,user)
    (buzz.buzz_members.pluck(:user_id).include?(user.id))
  end

  def check_for_response_users(buzz,user_id)
    (buzz.response_expected_buzzs.pluck(:user_id).include?(user_id))?"checked":" "
  end

  def check_for_priority_buzz_users(buzz,user_id)
    (buzz.priority_buzzs.pluck(:user_id).include?(user_id))?"checked":" "
  end
  
  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to_function(name, 'remove_fields(this)')
  end

  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")")
  end

  def buzzers_count
    User.joins(:buzzs).group('user_id').having("count(*) > 0 ").length
  end

  def channel_count
    Channel.select('id').where(:is_cug => false).count
  end

  def cug_count
    Channel.select('id').where(:is_cug => true).count
  end

  def buzzes_count
    Buzz.select('id').count
  end

  def check_channel_is_fav(user,id)
    WatchChannel.select("id").where(:channel_id => id, :user_id => user.id).first
  end

  def check_cug_is_fav(user,id)
    WatchChannel.select("id").where(:channel_id => id, :user_id => user.id).first
  end

  def get_cug_alias_name(user, cug)
    ChannelAlias.select("name,id").where(:user_id => user, :channel_id => cug).first.try(:name)
  end

  def tooltip_view
    current_user.user_preference.tooltip_view
  end

  def buzz_flags_tool_tip(buzz_flag)
    flags = []
    flags << "<ul class = 'flag_tooltip'>"
    buzz_flag.each do |flag|
        expiry_date = flag.expiry_date
      flags << "<li class='clear'>
                <div class='image_icon'><img src='assets/flag_#{flag.flag.name.downcase}.png' /></div>
                <div class='date_text'> #{expiry_date.nil? ? 'Never expires': expiry_date.strftime("%d-%m-%Y")}</div>
                 </li>"
    end
    flags << "</ul>"
  end

  def response_expected_tooltip(response_members)
    response_title = "<table class='dozz_tooltip' cellpadding='0' cellspacing='0'>
                    <tr>
                      <td colspan='2'class='response_title'>Response Expected</td>
                    </tr>
                    <tr>
                    <th>Name</th>
                    </tr>"
    response_members.each do |member|
      response_title += "<tr>
                      <td>#{member.full_name}</td>
                      </tr>"
    end
    response_title += "</table>"
  end
  
  def buzz_dozz_tool_tip(buzz_tasks)
    if  buzz_tasks.size > 0
      dozz_title = "<table class='dozz_tooltip' cellpadding='0' cellspacing='0'>
                    <tr>
                    <th>Dozz</th>
                    <th>Priority</th>
                    <th>Due date</th>
                    </tr>"
      buzz_tasks.each do |t|
        dozz_title += "<tr>
                      <td>#{t.name}</td>
                      <td>#{t.priority}</td>
                      <td>#{t.due_date.blank? ? '-' : t.due_date}</td>
                      </tr>"
      end
      dozz_title += "</table>"
    else
      dozz_title = "View/Create Dozz"
    end
  end

  def get_beehive_child_or_parent(id)
    beehive_view = BeehiveView.find(id)
    beehive_view.has_children? ? beehive_view.children.first.id : id
  end

  def autoresponse_msg(msg)
    message = ""
    return message if (msg.nil? || msg.blank?)
    if msg.is_a?(Array)
      msg.each{|m| message << m }
    else
      message << m
    end
    message
  end

end