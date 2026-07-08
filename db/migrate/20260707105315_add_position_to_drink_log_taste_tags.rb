class AddPositionToDrinkLogTasteTags < ActiveRecord::Migration[8.1]
  def up
    add_column :drink_log_taste_tags, :position, :integer

    execute <<~SQL.squish
      UPDATE drink_log_taste_tags
      SET position = ordered.position
      FROM (
        SELECT
          id,
          ROW_NUMBER() OVER (
            PARTITION BY drink_log_id
            ORDER BY created_at, id
          ) AS position
        FROM drink_log_taste_tags
      ) ordered
      WHERE drink_log_taste_tags.id = ordered.id
    SQL

    change_column_null :drink_log_taste_tags, :position, false

    add_index :drink_log_taste_tags,
              [:drink_log_id, :position],
              unique: true,
              name: "index_drink_log_taste_tags_on_drink_log_id_and_position"
  end

  def down
    remove_index :drink_log_taste_tags,
                 name: "index_drink_log_taste_tags_on_drink_log_id_and_position"

    remove_column :drink_log_taste_tags, :position
  end
end