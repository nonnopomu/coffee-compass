class RemoveBrewMethodFromDrinkLogs < ActiveRecord::Migration[8.1]
  class MigrationTag < ActiveRecord::Base
    self.table_name = "tags"
  end

  class MigrationCafeTag < ActiveRecord::Base
    self.table_name = "cafe_tags"
  end

  def up
    brew_method_tag_ids = MigrationTag.where(category: 2).pluck(:id)

    MigrationCafeTag.where(tag_id: brew_method_tag_ids).delete_all

    remove_foreign_key :drink_logs, column: :brew_method_tag_id
    remove_index :drink_logs, column: :brew_method_tag_id
    remove_column :drink_logs, :brew_method_tag_id, :bigint

    MigrationTag.where(id: brew_method_tag_ids).delete_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
