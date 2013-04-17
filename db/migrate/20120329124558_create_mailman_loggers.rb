class CreateMailmanLoggers < ActiveRecord::Migration
  def change
    create_table :mailman_loggers do |t|
      t.string  :sender
      t.string  :subject
      t.text    :message
      t.text    :response
      t.string  :status
      t.timestamps
    end
  end
end
