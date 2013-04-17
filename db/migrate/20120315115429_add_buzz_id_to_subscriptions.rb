class AddBuzzIdToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :buzz_id, :integer

  end
end
