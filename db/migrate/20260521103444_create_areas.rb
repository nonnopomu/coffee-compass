class CreateAreas < ActiveRecord::Migration[7.2]
  def change
    create_table :areas do |t|
      t.string :name, null: false
      t.string :prefecture, null: false
      t.string :city, null: false

      t.timestamps
    end

    add_index :areas, [ :prefecture, :city, :name ], unique: true
    add_index :areas, :name
    add_index :areas, :prefecture
    add_index :areas, :city
  end
end
