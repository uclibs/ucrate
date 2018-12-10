# frozen_string_literal: true
class WorkAndFileIndex < ActiveRecord::Migration[5.0]
  def change
    create_table :work_and_file_indices do |t|
      t.string :object_id
      t.string :object_type
      t.string :user_email
      t.datetime :stats_last_gathered
      t.timestamps null: false
    end
  end
end
