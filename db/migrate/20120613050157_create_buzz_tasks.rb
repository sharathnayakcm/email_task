class CreateBuzzTasks < ActiveRecord::Migration
  def change
    create_table :buzz_tasks do |t|
      t.references :user, :null => false
      t.references :buzz, :null => false
      t.string :name, :limit => 100
      t.date :due_date
      t.enum :priority, :limit => [:high, :medium, :low]
      t.boolean :status, :default => 0, :null => false
      t.timestamps
    end
  end
end
