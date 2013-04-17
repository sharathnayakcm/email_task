class AddOwnerIdForResponseExpectedBuzz < ActiveRecord::Migration
  def up
    add_column :response_expected_buzzs, :owner_id, :integer
  end

  def down
  end
end
