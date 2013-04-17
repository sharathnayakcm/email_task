class BeehiveView < ActiveRecord::Base
  has_ancestry

  #Default Cug View
  def self.default_cug_view
    where(:view_name => 'Action').first
  end

  #Default Channel View
  def self.default_channel_view
    where(:view_name => 'My Channels').first
  end

  #Getting view name
  def self.get_name(id)
    id && find(id).view_name
  end

  #Getting all the cugs views
  def self.default_cug_views
    where('view_for=? and ancestry is null','cug')
  end

  #Getting all the channel views
  def self.default_channel_views
    where('view_for=? and ancestry is null','channel')
  end

  def self.get_view_id(id)
    find(id)
  end

  def self.get_view_id_by_name(name)
    where("view_name=? and ancestry is not null", name).first
  end

  def self.get_view_by_name(name)
     where("view_name=? and ancestry is null", name).first
  end

  def self.find_view_related_cugs(current_user, view1, view2, hide_insync_cug)
    beehive_view = BeehiveView.get_view_id_by_name(view1)
    cugs = current_user.get_cugs_unsync_count(current_user.send("updating_#{beehive_view.view_scope}"), hide_insync_cug)
    beehive_view_for_normal = BeehiveView.get_view_id_by_name(view2)
    normal_cugs = current_user.get_cugs_unsync_count(current_user.send("updating_#{beehive_view.view_scope}"), hide_insync_cug)
    return beehive_view, beehive_view_for_normal, cugs, normal_cugs
  end

  def self.get_path(view)
    bv = self.find view
    return bv.parametrized_link
  end
end