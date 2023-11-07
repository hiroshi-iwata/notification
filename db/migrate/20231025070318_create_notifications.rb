class CreateNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :notifications do |t|
      #t.integer :relationship_id
      t.string :message
      t.string :action
      t.references :user, null: false, foreign_key: true
      t.references :relationship, null: true, foreign_key: true

      t.timestamps
    end
    #add_index :notifications, [:relationship_id]
    #add_index :notifications, [:user_id]
  end
end
