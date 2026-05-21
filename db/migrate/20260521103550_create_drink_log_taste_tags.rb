class CreateDrinkLogTasteTags < ActiveRecord::Migration[7.2]
  def change
    create_table :drink_log_taste_tags do |t|
      t.references :drink_log, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end

    add_index :drink_log_taste_tags, [ :drink_log_id, :tag_id ], unique: true
  end
end
