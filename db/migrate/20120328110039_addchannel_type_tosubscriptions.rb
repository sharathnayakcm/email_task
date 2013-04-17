class AddchannelTypeTosubscriptions < ActiveRecord::Migration
  def up
     add_column :subscriptions, :is_core, :boolean,:default => true
  end

  def down
     remove_column :subscriptions, :is_core
  end
end
