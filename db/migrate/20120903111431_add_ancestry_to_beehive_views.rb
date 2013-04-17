class AddAncestryToBeehiveViews < ActiveRecord::Migration
  def change
    add_column :beehive_views, :ancestry, :string
    add_index  :beehive_views, :ancestry
  end
end
