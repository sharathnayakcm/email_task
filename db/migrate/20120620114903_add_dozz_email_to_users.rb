class AddDozzEmailToUsers < ActiveRecord::Migration
  def up
    add_column :users, :dozz_email, :string
  end

  def down
    remove_column :users, :dozz_email
  end
end
