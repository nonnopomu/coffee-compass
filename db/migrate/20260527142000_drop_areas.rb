class DropAreas < ActiveRecord::Migration[7.2]
  def change
    drop_table :areas do |t|
      t.string :name, null: false
      t.string :prefecture, null: false
      t.string :city, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.string :region

      t.index [ :city ], name: "index_areas_on_city"
      t.index [ :name ], name: "index_areas_on_name"
      t.index [ :prefecture, :city, :name ], name: "index_areas_on_prefecture_and_city_and_name", unique: true
      t.index [ :prefecture ], name: "index_areas_on_prefecture"
    end
  end
end
