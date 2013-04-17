class AddParametrizeToBeehiveView < ActiveRecord::Migration
  def change
    add_column :beehive_views, :parametrized_link, :string
  end
end
