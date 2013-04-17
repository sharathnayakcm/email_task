class CreateBuzzInsyncs < ActiveRecord::Migration
  def change
    create_table :buzz_insyncs do |t|
      t.integer :channel_id
      t.integer :buzz_id
      t.integer :user_id

      t.timestamps
    end
  end
end
