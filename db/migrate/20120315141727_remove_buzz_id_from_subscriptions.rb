class RemoveBuzzIdFromSubscriptions < ActiveRecord::Migration
  def up
    remove_column :subscriptions, :buzz_id
      end

  def down
    add_column :subscriptions, :buzz_id, :integer
  end
end
