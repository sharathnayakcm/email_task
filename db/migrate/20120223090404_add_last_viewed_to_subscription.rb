class AddLastViewedToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions, :last_viewed, :datetime

  end
end
