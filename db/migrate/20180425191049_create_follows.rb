class CreateFollows < ActiveRecord::Migration[5.1]
  def change
    create_table :follows do |t|
      t.integer :userOne_id
      t.integer :userTwo_id 
      t.timestamps
    end
  end
end
