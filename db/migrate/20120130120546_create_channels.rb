class CreateChannels < ActiveRecord::Migration
  def change
    create_table :channels do |t|
      t.string  :name
      t.boolean :is_cug,    :default => false
      t.integer :user_id
      t.boolean :is_active, :default => true

      t.timestamps
    end
  end
end