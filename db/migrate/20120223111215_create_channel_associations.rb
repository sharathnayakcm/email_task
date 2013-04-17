class CreateChannelAssociations < ActiveRecord::Migration
  def change
    create_table :channel_associations do |t|
      t.integer :channel_id
      t.integer :cug_id

      t.timestamps
    end
  end
end
