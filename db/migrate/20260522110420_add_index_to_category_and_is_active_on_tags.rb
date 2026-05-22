class AddIndexToCategoryAndIsActiveOnTags < ActiveRecord::Migration[7.2]
  def change
    add_index :tags, [ :category, :is_active ]
  end
end
