class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.text :company_info

      t.timestamps
    end
  end
end
