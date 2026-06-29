class AddFlavorMetadataToTags < ActiveRecord::Migration[8.1]
  def change
    add_reference :tags, :parent, foreign_key: { to_table: :tags }, index: true
    add_column :tags, :color_hex, :string
    add_column :tags, :beginner_display_order, :integer
  end
end
