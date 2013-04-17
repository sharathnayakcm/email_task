class CreateBuzzMembers < ActiveRecord::Migration
  def change
    create_table :buzz_members do |t|
      t.integer :user_id
      t.integer :buzz_id
      t.integer :channel_id
      t.timestamps
    end
  end
end
