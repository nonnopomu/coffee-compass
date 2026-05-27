class ReplaceAreaWithPrefectureOnCafes < ActiveRecord::Migration[7.2]
  def change
    add_column :cafes, :prefecture, :string, null: false
    add_index :cafes, :prefecture
    remove_reference :cafes, :area, foreign_key: true
  end
end
