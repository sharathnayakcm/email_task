class ChangeDataTypeForBuzzMessage < ActiveRecord::Migration
  def change
    change_column :buzzs, :message, :text
  end

end
