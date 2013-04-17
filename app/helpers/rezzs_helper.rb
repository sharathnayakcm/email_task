module RezzsHelper
  def buzz_dozz_link(buzz)
    buzz_tasks = buzz.buzz_tasks.select("name, priority,due_date").where(:user_id => current_user.id)
    dozz_title = buzz_dozz_tool_tip(buzz_tasks)
    buzz_tasks.size > 0 ? [title = dozz_title,
      count = "#{buzz_tasks.size}"] : [title = dozz_title, count = '']
    content_tag(:li, :id => "task_div_#{buzz.id}") do
      content_tag(:a, :href => buzz_tasks_path(:buzz_id => buzz.id), :id => "buzz_dozz_img_#{buzz.id}", "data-remote" => true, :class => "dozz apple_overlay_link" , :title => "#{title}", :rel => "#overlay_block") do
        content_tag(:span, :id => "dozz_tasks_incom_count_#{buzz.id}", :class => "#{count.blank? ? '' : 'buzz_icons_count'}") do
          "#{count}".html_safe
        end
      end
    end
  end

  def buzz_tag_link(buzz)
    tags = buzz.tags.select("name").map(&:name)
    tags.size > 0 ? [title = tags.join(", "),
      count = "#{tags.size}"] : [title = "Add Tag", count ='']
    content_tag(:li, :id => "tag_div_#{buzz.id}") do
      content_tag(:a, :href => buzz_tags_path(:channel_id => buzz.channel_id, :buzz_id => buzz.id), "data-remote" => true, :class => "tag apple_overlay_link", :title => "#{title}", :id => "buzz_tag_img_#{buzz[:id]}" , :rel => "#overlay_block") do
        content_tag(:span, :id => "buzz_tag_count_#{buzz[:id]}", :class => "#{count.blank? ? '' : 'buzz_icons_count'}") do
          "#{count}".html_safe
        end
      end
    end
  end
  
  def limit_buzz_link(buzz)
    buzz_members = buzz.buzz_members_details.select("last_name, first_name, display_name").map(&:full_name)
    if buzz.user_id == current_user.id  && !buzz.ancestry
      title =  buzz_members.size > 0 ? buzz_members.join(', ') : "Limit Buzz"
      content_tag(:li, :id => "limit_buzz_#{buzz.id}", :class => "limit_img") do
        content_tag(:a, :href => limit_buzz_buzz_path(current_user,:channel_id => buzz.channel_id,:buzz_id => buzz.id, :update_div => "update_limit_buzz_#{buzz.id}", :name_update_div => "limit_buzz_#{buzz.id}"), "data-remote" => true, :class => "limit apple_overlay_link", :id => "limit_buzz_img_#{buzz.id}", :title => title, :rel => "#overlay_block") do
          content_tag(:span, :id => "buzz_limit_count_#{buzz.id}", :class => "#{buzz_members.size > 0 ? 'buzz_icons_count' : ''}") do
            "#{buzz_members.size}".html_safe if buzz_members.size > 0
          end
        end
      end
    else
      if buzz_members.any?
        content_tag(:li)do
          content_tag(:a, :href => "javascript:void(0)", :class => "limit", :onclick => "cannot_rezz_out();", :title => "#{buzz_members.size > 0 ? buzz_members.join(', ') : ''}") do
            content_tag(:span, :class => "buzz_limit_count_#{buzz[:id]} #{buzz_members.size > 0 ? 'buzz_icons_count' : ''}") do
              "#{buzz_members.size}".html_safe if buzz_members.size > 0
            end
          end
        end
      end
    end
  end

  def response_expected_link(buzz)
    response_members = buzz.responded_users.select("last_name, first_name, display_name")
    if buzz.user_id == current_user.id
      title =  response_members.count > 0 ? response_expected_tooltip(response_members) : "Set Response Expected"
      content_tag(:li, :id => "response_buzz_#{buzz.id}", :class => "response_img") do
        content_tag(:a, :href => new_response_expected_buzz_path(:user_id => current_user.id, :buzz_id => buzz.id), "data-remote" => true, :class => "response apple_overlay_link", :id => "response_buzz_img_#{buzz.id}", :title => title, :rel => "#overlay_block") do
          content_tag(:span, :id => "buzz_response_count_#{buzz.id}", :class => "#{response_members.count > 0 ? 'buzz_icons_count' : ''}") do
            "#{response_members.count}".html_safe if response_members.count > 0
          end
        end
      end
    end
  end

  def priorty_buzz_link(buzz)
    if buzz.user_id == current_user.id
      buzz_members = buzz.priority_buzz_users.select("last_name, first_name, display_name").map(&:full_name)
      title =  buzz_members.size > 0 ? buzz_members.join(', ') : "Set Priority"
      content_tag(:li, :id => "priority_buzz_#{buzz.id}", :class => "limit_img") do
        content_tag(:a, :href => new_priority_buzz_path(:user_id => current_user.id, :buzz_id => buzz.id), "data-remote" => true, :class => "priority_buzz apple_overlay_link", :id => "priority_buzz_img_#{buzz.id}", :title => title, :rel => "#overlay_block") do
          content_tag(:span, :id => "priority_buzz_count_#{buzz.id}", :class => "#{buzz_members.size > 0 ? 'buzz_icons_count' : ''}") do
            "#{buzz_members.size}".html_safe if buzz_members.size > 0
          end
        end
      end
    end
  end


  def create_and_view_rezz_link(buzz)
    rezz_count = buzz.root.subtree.count
    content_tag(:li, :id => "view_#{buzz[:id]}") do
      content_tag(:a, :href => new_rezz_path(:buzz_id => buzz.id), "data-remote" => true , :class => 'rezz_img rezz_icon apple_overlay_link', :id => "rezz_img_#{buzz.id}" , :title => 'Create Rezz', :rel => "#overlay_block") do
        content_tag(:span, :class => "parent_#{buzz.root_id} #{rezz_count > 1 ? 'buzz_icons_count' : ''}") do
          "#{rezz_count}".html_safe if rezz_count > 1
        end
      end
    end
  end

  def view_rezzs_toggle(buzz)
    content_tag(:a, :href => rezzs_path(:buzz_id => buzz.id), "data-remote" => true , :class => 'arrow_rezz_icon', :id => "arrow_rezz_icon_#{buzz.id}" , :title => 'View Rezz(s)') do
    end
  end


  def buzz_insync_link(buzz, insync_link)
    link_array = []
    if insync_link && buzz.id.to_i > insync_link.to_i && buzz.user_id.to_i != current_user.id
      link_array << content_tag(:li, :id => "insync_div_#{buzz.id}", :class => "#{buzz.channel_id}_insync_buzz unsync_buzz") do
        "#{link_to( "&nbsp".html_safe, 'javascript://', :path => insync_buzz_in_channel_buzzs_path(:id => buzz.channel_id, :buzz_id => buzz.id), :remote => true, :class => "insync", :title => 'Insync')}".html_safe
      end
    end
    link_array.join(" ").html_safe
  end
  
  
  def remove_buzz_link(buzz)
    if buzz.channel.is_admin?(current_user)
      content_tag(:li) do
        content_tag(:a, :href => rezz_path(buzz, :buzz_id=> buzz.root_id), "data-confirm" => "Are you sure you want to remove this buzz?", "data-method" => "delete", "data-remote" => "true", :class => 'delete',:title =>'Remove Buzz') do  end
      end
    end
  end
  

  def get_buzz_attachment(buzz_attachment_name, id)
    link_array = []
    link_array << content_tag(:span) do
      image_tag('attachment.png')
    end
    link_array << content_tag(:span) do
      link_to buzz_attachment_name, download_attachment_home_index_path(:id => id), :target => '_blank'
    end
    link_array.join(" ").html_safe
  end
  
  def buzz_name_link(buzz, buzz_name)
    content_tag(:li) do
      link_to "&nbsp".html_safe, new_buzz_name_path(:buzz_id => buzz.id) ,:class =>  "buzz_name parent_buzz_name_view_#{buzz.root_id} apple_overlay_link", :remote => true,  :id => "buzz_name_icon_#{buzz.id}", :rel => "#overlay_block", :title =>"Add Buzz Name",:style => "display : #{buzz_name.blank? ? 'block' : 'none'}"
    end
  end
  
  def buzz_flag_link(buzz,user)
    buzz_flags =  buzz.buzz_flags.not_expired(user.id)
    flag_count = buzz_flags.count
    title = flag_count > 0 ? buzz_flags_tool_tip(buzz_flags).join.html_safe : 'Add Flag'
    content_tag(:li, :id => "flag_div_#{buzz.id}",:class=> "flag_list") do
      content_tag(:a, :href => buzz_flags_path(:buzz_id => buzz.id), "data-remote" => true, :id => buzz.id, :class => "flag buzz_flag_#{buzz.id} apple_overlay_link", :rel => "#overlay_block", :title => "#{title}") do
        content_tag(:span, :class => "flag_count_#{buzz.id} #{flag_count > 0 ? 'buzz_icons_count' : ''}") do
          "#{flag_count}".html_safe if flag_count > 0
        end
      end
    end
  end
end

