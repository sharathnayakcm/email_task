class AddOwnerIdForPriorityBuzz < ActiveRecord::Migration
  def up
    add_column :priority_buzzs, :owner_id, :integer
  end

  def down
  end
end
