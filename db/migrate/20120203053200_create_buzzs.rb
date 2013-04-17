class CreateBuzzs < ActiveRecord::Migration
  def change
    create_table :buzzs do |t|
      t.string :message
      t.integer :channel_id
      t.integer :user_id
      t.boolean :priority

      t.timestamps
    end
  end
end
