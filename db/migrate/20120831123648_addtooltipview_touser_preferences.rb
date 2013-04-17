class AddtooltipviewTouserPreferences < ActiveRecord::Migration
  def up
     add_column :user_preferences, :tooltip_view, :string, default: 'long'
  end

  def down
     remove_column :user_preferences, :tooltip_view
  end
end
