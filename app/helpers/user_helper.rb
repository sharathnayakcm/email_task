module UserHelper

  #show the activation/deactivation link according to the user status
  def user_status_link(user)
    if user.is_active
      link_to image_tag("social/delete.png", :alt =>"Delete", :style=> "width:14px; height:14px; border:0"), deactivate_admin_user_path(user), :method => :put
    else
      link_to image_tag("social/accept.png", :alt =>"Delete", :style=> "width:14px; height:14px; border:0"), activate_admin_user_path(user), :method => :put
    end
  end
end