class AddDormantDaysForUsers < ActiveRecord::Migration
  def up
    add_column :users, :dormant_days, :integer,:default=> 2
  end

  def down
  end
end
