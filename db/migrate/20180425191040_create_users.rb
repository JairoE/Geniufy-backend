class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :username
      t.string :spotify_url
      t.string :href
      t.string :uri
      t.string :access_token
      t.string :refresh_token
      t.timestamps
    end
  end
end
