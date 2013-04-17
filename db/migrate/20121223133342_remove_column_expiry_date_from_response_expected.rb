class RemoveColumnExpiryDateFromResponseExpected < ActiveRecord::Migration
  def up
    remove_column :response_expected_buzzs, :expiry_date
  end

  def down
  end
end
