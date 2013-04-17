class CreateResponseExpectedBuzzs < ActiveRecord::Migration
  def change
    create_table :response_expected_buzzs do |t|
      t.integer :buzz_id
      t.integer  :user_id
      t.date     :expiry_date
      t.timestamps
    end
  end
end
