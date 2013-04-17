class AddShowInsyncToBeehiveViews < ActiveRecord::Migration
  def change
    add_column :beehive_views, :show_insync, :boolean, :default => false
  end
end
