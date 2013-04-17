class CreateBeehiveViews < ActiveRecord::Migration

  def change
    create_table :beehive_views do |t|
      t.integer :owner_id
      t.string  :view_name, :null => false
      t.string  :view_type
      t.enum    :view_for, :limit => [:channel, :cug]
      t.timestamps
    end
  end

end
