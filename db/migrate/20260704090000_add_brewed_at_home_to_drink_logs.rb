class AddBrewedAtHomeToDrinkLogs < ActiveRecord::Migration[8.1]
  def change
    add_column :drink_logs, :brewed_at_home, :boolean, null: false, default: false
    change_column_null :drink_logs, :cafe_id, true
  end
end
