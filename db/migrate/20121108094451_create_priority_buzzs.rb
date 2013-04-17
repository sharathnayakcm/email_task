class CreatePriorityBuzzs < ActiveRecord::Migration
  def change
    create_table :priority_buzzs do |t|
      t.integer :buzz_id
      t.integer  :user_id
      t.timestamps
    end
  end
end
