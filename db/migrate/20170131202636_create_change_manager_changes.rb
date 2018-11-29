class CreateChangeManagerChanges < ActiveRecord::Migration[5.1]
    def change
      create_table :change_manager_changes do |t|
        t.string :change_type
        t.boolean :cancelled
        t.datetime :notified
        t.string :owner
        t.string :target
        t.string :context
        t.timestamps
      end
    end
  end