class AddAttachmentToBuzz < ActiveRecord::Migration
  def change
    add_column :buzzs, :attachment, :string

  end
end
