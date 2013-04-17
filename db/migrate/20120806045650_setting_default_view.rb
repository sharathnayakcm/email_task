class SettingDefaultView < ActiveRecord::Migration
  def up
    remove_column :user_preferences, :default_view
  end
  
  def change
    add_column :user_preferences, :cug_view, :string
    add_column :user_preferences, :channel_view, :string
  end

  def down
    add_column :user_preferences, :default_view, :integer
  end
end
