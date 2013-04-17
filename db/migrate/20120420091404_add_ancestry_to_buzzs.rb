class AddAncestryToBuzzs < ActiveRecord::Migration
  def up
    add_column :buzzs, :ancestry, :string
    add_index  :buzzs, :ancestry
  end
  
  def down
    remove_column :buzzs, :ancestry
    remove_index  :buzzs, :ancestry
  end
end
