class CreateUserPreferences < ActiveRecord::Migration
  def change
    create_table :user_preferences do |t|
      t.integer :user_id
      t.integer :default_view
      t.string  :buzz_rate_1
      t.string  :buzz_rate_2

      t.timestamps
    end
  end
end
