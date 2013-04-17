class AddInsyncInPriorityBuzzs < ActiveRecord::Migration
  def up
    add_column :priority_buzzs, :insync, :boolean, :default => false
  end

  def down
  end
end
