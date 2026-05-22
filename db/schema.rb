# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_05_22_110420) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "areas", force: :cascade do |t|
    t.string "name", null: false
    t.string "prefecture", null: false
    t.string "city", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city"], name: "index_areas_on_city"
    t.index ["name"], name: "index_areas_on_name"
    t.index ["prefecture", "city", "name"], name: "index_areas_on_prefecture_and_city_and_name", unique: true
    t.index ["prefecture"], name: "index_areas_on_prefecture"
  end

  create_table "cafe_tags", force: :cascade do |t|
    t.bigint "cafe_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cafe_id", "tag_id"], name: "index_cafe_tags_on_cafe_id_and_tag_id", unique: true
    t.index ["cafe_id"], name: "index_cafe_tags_on_cafe_id"
    t.index ["tag_id"], name: "index_cafe_tags_on_tag_id"
  end

  create_table "cafes", force: :cascade do |t|
    t.bigint "area_id", null: false
    t.string "name", null: false
    t.string "address", null: false
    t.text "opening_hours"
    t.text "closed_days"
    t.text "website_url"
    t.text "instagram_url"
    t.text "google_maps_url", null: false
    t.text "description"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["area_id", "status"], name: "index_cafes_on_area_id_and_status"
    t.index ["area_id"], name: "index_cafes_on_area_id"
    t.index ["name", "address"], name: "index_cafes_on_name_and_address", unique: true
    t.index ["name"], name: "index_cafes_on_name"
    t.index ["status"], name: "index_cafes_on_status"
  end

  create_table "drink_log_taste_tags", force: :cascade do |t|
    t.bigint "drink_log_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["drink_log_id", "tag_id"], name: "index_drink_log_taste_tags_on_drink_log_id_and_tag_id", unique: true
    t.index ["drink_log_id"], name: "index_drink_log_taste_tags_on_drink_log_id"
    t.index ["tag_id"], name: "index_drink_log_taste_tags_on_tag_id"
  end

  create_table "drink_logs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "cafe_id", null: false
    t.string "menu_name", null: false
    t.date "drank_on", null: false
    t.bigint "roast_level_tag_id", null: false
    t.bigint "brew_method_tag_id", null: false
    t.text "memo"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["brew_method_tag_id"], name: "index_drink_logs_on_brew_method_tag_id"
    t.index ["cafe_id", "status", "created_at"], name: "index_drink_logs_on_cafe_id_and_status_and_created_at"
    t.index ["cafe_id"], name: "index_drink_logs_on_cafe_id"
    t.index ["created_at"], name: "index_drink_logs_on_created_at"
    t.index ["drank_on"], name: "index_drink_logs_on_drank_on"
    t.index ["roast_level_tag_id"], name: "index_drink_logs_on_roast_level_tag_id"
    t.index ["status"], name: "index_drink_logs_on_status"
    t.index ["user_id", "status", "drank_on"], name: "index_drink_logs_on_user_id_and_status_and_drank_on"
    t.index ["user_id"], name: "index_drink_logs_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.integer "category", null: false
    t.integer "display_order", default: 0, null: false
    t.boolean "is_active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category", "display_order"], name: "index_tags_on_category_and_display_order"
    t.index ["category", "is_active"], name: "index_tags_on_category_and_is_active"
    t.index ["category", "name"], name: "index_tags_on_category_and_name", unique: true
    t.index ["category"], name: "index_tags_on_category"
    t.index ["is_active"], name: "index_tags_on_is_active"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", default: "", null: false
    t.integer "role", default: 0, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "cafe_tags", "cafes"
  add_foreign_key "cafe_tags", "tags"
  add_foreign_key "cafes", "areas"
  add_foreign_key "drink_log_taste_tags", "drink_logs"
  add_foreign_key "drink_log_taste_tags", "tags"
  add_foreign_key "drink_logs", "cafes"
  add_foreign_key "drink_logs", "tags", column: "brew_method_tag_id"
  add_foreign_key "drink_logs", "tags", column: "roast_level_tag_id"
  add_foreign_key "drink_logs", "users"
end
