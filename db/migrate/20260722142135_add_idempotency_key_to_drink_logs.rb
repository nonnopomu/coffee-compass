class AddIdempotencyKeyToDrinkLogs < ActiveRecord::Migration[8.1]
  def up
    add_column :drink_logs, :idempotency_key, :string

    DrinkLog.reset_column_information

    DrinkLog.find_each do |drink_log|
      drink_log.update_columns(idempotency_key: SecureRandom.uuid)
    end

    change_column_null :drink_logs, :idempotency_key, false

    add_index :drink_logs, [:user_id, :idempotency_key], unique: true
  end

  def down
    remove_index :drink_logs, column: [:user_id, :idempotency_key]
    remove_column :drink_logs, :idempotency_key
  end
end
