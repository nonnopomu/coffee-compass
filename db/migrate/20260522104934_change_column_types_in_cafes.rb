class ChangeColumnTypesInCafes < ActiveRecord::Migration[7.2]
  def change
    change_column :cafes, :google_maps_url, :text
    change_column :cafes, :website_url, :text
    change_column :cafes, :instagram_url, :text
    change_column :cafes, :closed_days, :text
  end
end
