class CreateAnnotationThreads < ActiveRecord::Migration[5.1]
  def change
    create_table :annotation_threads do |t|
      t.integer :annotation_id
      t.integer :chained_annotation_Id
      t.timestamps
    end
  end
end
