class CreateCollectionExports < ActiveRecord::Migration[5.1]
  def change
    create_table :collection_exports do |t|
      t.string :collection_id
      t.string :user
      t.binary :export_file

      t.timestamps
    end
  end
end
