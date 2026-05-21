class CreateTags < ActiveRecord::Migration[7.2]
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.integer :category, null: false
      t.integer :display_order, null: false, default: 0
      t.boolean :is_active, null: false, default: true

      t.timestamps
    end

    add_index :tags, [:category, :name], unique: true
    add_index :tags, :category
    add_index :tags, :is_active
    add_index :tags, [:category, :display_order]
  end
end
