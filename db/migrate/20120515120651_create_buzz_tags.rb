class CreateBuzzTags < ActiveRecord::Migration
  def change
    create_table :buzz_tags do |t|
      t.integer :buzz_id
      t.integer :tag_id

      t.timestamps
    end
  end
end
