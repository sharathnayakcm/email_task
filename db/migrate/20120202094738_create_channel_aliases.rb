class CreateChannelAliases < ActiveRecord::Migration
  def change
    create_table :channel_aliases do |t|
      t.string :name
      t.integer :channel_id
      t.integer :user_id

      t.timestamps
    end
  end
end
