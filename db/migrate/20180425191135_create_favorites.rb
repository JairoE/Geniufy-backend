class CreateFavorites < ActiveRecord::Migration[5.1]
  def change
    create_table :favorites do |t|
      t.integer :user_id
      t.integer :song_id
      t.string :lyric_portion
      t.timestamps
    end
  end
end
