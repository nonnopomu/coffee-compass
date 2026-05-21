class CreateCafes < ActiveRecord::Migration[7.2]
  def change
    create_table :cafes do |t|
      t.references :area, null: false, foreign_key: true
      t.string :name, null: false
      t.string :address, null: false
      t.text :opening_hours
      t.string :closed_days
      t.string :website_url
      t.string :instagram_url
      t.string :google_maps_url, null: false
      t.text :description
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :cafes, [ :name, :address ], unique: true
    add_index :cafes, :status
    add_index :cafes, [ :area_id, :status ]
    add_index :cafes, :name
  end
end
