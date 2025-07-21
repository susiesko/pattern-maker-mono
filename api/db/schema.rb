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

ActiveRecord::Schema[8.0].define(version: 2025_07_21_202610) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "bead_brands", force: :cascade do |t|
    t.string "name", null: false
    t.string "website"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "beads", force: :cascade do |t|
    t.string "name", null: false
    t.string "brand_product_code", null: false
    t.json "metadata"
    t.bigint "brand_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image"
    t.string "shape"
    t.string "size"
    t.string "color_group"
    t.string "glass_group"
    t.string "finish"
    t.string "dyed"
    t.string "galvanized"
    t.string "plating"
    t.index ["brand_id", "color_group"], name: "index_beads_on_brand_id_and_color_group"
    t.index ["brand_id", "finish"], name: "index_beads_on_brand_id_and_finish"
    t.index ["brand_id", "size"], name: "index_beads_on_brand_id_and_size"
    t.index ["brand_id"], name: "index_beads_on_brand_id"
    t.index ["brand_product_code"], name: "index_beads_on_brand_product_code", unique: true
    t.index ["dyed"], name: "index_beads_on_dyed"
    t.index ["galvanized"], name: "index_beads_on_galvanized"
    t.index ["glass_group"], name: "index_beads_on_glass_group"
    t.index ["plating"], name: "index_beads_on_plating"
  end

  create_table "inventories", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "bead_id", null: false
    t.decimal "quantity", precision: 10, scale: 3, default: "0.0", null: false
    t.string "quantity_unit", default: "unit", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bead_id"], name: "index_inventories_on_bead_id"
    t.index ["user_id", "bead_id"], name: "index_inventories_on_user_id_and_bead_id", unique: true
    t.index ["user_id"], name: "index_inventories_on_user_id"
  end

  create_table "user_inventory_settings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.json "field_definitions", default: [], null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_inventory_settings_on_user_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "first_name"
    t.string "last_name"
    t.boolean "admin", default: false
    t.datetime "last_login_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "beads", "bead_brands", column: "brand_id"
  add_foreign_key "inventories", "beads"
  add_foreign_key "inventories", "users"
  add_foreign_key "user_inventory_settings", "users"
end
