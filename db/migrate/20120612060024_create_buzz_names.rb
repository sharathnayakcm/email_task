class CreateBuzzNames < ActiveRecord::Migration
  def change
    create_table :buzz_names do |t|
      t.integer :buzz_id
      t.integer :user_id
      t.string :name

      t.timestamps
    end
  end
end
