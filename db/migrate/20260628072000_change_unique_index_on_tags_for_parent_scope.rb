class ChangeUniqueIndexOnTagsForParentScope < ActiveRecord::Migration[8.1]
  def change
    remove_index :tags, name: "index_tags_on_category_and_name"

    add_index :tags,
              [ :category, :name ],
              unique: true,
              where: "parent_id IS NULL",
              name: "index_tags_on_category_and_name_without_parent"

    add_index :tags,
              [ :category, :parent_id, :name ],
              unique: true,
              where: "parent_id IS NOT NULL",
              name: "index_tags_on_category_parent_and_name"
  end
end
