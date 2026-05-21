class CreateDrinkLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :drink_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :cafe, null: false, foreign_key: true
      t.string :menu_name, null: false
      t.date :drank_on, null: false
      t.bigint :roast_level_tag_id, null: false
      t.bigint :brew_method_tag_id, null: false
      t.text :memo
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_foreign_key :drink_logs, :tags, column: :roast_level_tag_id
    add_foreign_key :drink_logs, :tags, column: :brew_method_tag_id

    add_index :drink_logs, :roast_level_tag_id
    add_index :drink_logs, :brew_method_tag_id
    add_index :drink_logs, :status
    add_index :drink_logs, :drank_on
    add_index :drink_logs, :created_at
    add_index :drink_logs, [:user_id, :status, :drank_on]
    add_index :drink_logs, [:cafe_id, :status, :created_at]
  end
end
