class AddViewScopeToBeehiveViews < ActiveRecord::Migration
  def change
    add_column :beehive_views, :view_scope, :string

  end
end
