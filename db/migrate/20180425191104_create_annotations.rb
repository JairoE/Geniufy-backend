class CreateAnnotations < ActiveRecord::Migration[5.1]
  def change
    create_table :annotations do |t|
      t.integer :song_id
      t.integer :user_id
      t.string :annotation
      t.integer :likes
      t.integer :dislikes 
      t.timestamps
    end
  end
end
