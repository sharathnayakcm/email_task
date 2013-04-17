class CreateBuzzFlags < ActiveRecord::Migration
  def change
    create_table :buzz_flags do |t|
      t.integer :buzz_id
      t.integer  :flag_id
      t.integer  :user_id
      t.date     :expiry_date

      t.timestamps
    end
  end
end
