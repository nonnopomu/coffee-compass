class CreateCafeTags < ActiveRecord::Migration[7.2]
  def change
    create_table :cafe_tags do |t|
      t.references :cafe, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end

    add_index :cafe_tags, [ :cafe_id, :tag_id ], unique: true
  end
end
