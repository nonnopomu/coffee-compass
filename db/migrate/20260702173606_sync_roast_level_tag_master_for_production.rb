class SyncRoastLevelTagMasterForProduction < ActiveRecord::Migration[8.1]
  def up
    roast_level_names = [
      "浅煎り",
      "中浅煎り",
      "中煎り",
      "中深煎り",
      "深煎り"
    ]

    Tag.transaction do
      Tag.roast_level.update_all(is_active: false)

      roast_level_names.each.with_index(1) do |name, display_order|
        tag = Tag.roast_level.find_or_initialize_by(name:)
        tag.assign_attributes(
          display_order: display_order,
          is_active: true,
          parent: nil,
          beginner_display_order: nil,
          color_hex: nil
        )
        tag.save!
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
