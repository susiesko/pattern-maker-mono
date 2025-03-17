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

ActiveRecord::Schema[8.0].define(version: 2025_03_09_170034) do
  create_table "bead_brands", force: :cascade do |t|
    t.string "name", null: false
    t.string "website"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bead_color_links", force: :cascade do |t|
    t.integer "bead_id", null: false
    t.integer "color_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bead_id", "color_id"], name: "index_bead_color_links_on_bead_id_and_color_id", unique: true
    t.index ["bead_id"], name: "index_bead_color_links_on_bead_id"
    t.index ["color_id"], name: "index_bead_color_links_on_color_id"
  end

  create_table "bead_colors", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bead_finish_links", force: :cascade do |t|
    t.integer "bead_id", null: false
    t.integer "finish_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bead_id", "finish_id"], name: "index_bead_finish_links_on_bead_id_and_finish_id", unique: true
    t.index ["bead_id"], name: "index_bead_finish_links_on_bead_id"
    t.index ["finish_id"], name: "index_bead_finish_links_on_finish_id"
  end

  create_table "bead_finishes", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bead_sizes.rb", force: :cascade do |t|
    t.string "size", null: false
    t.json "metadata"
    t.integer "brand_id", null: false
    t.integer "type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["brand_id"], name: "index_bead_sizes_on_brand_id"
    t.index ["type_id"], name: "index_bead_sizes_on_type_id"
  end

  create_table "bead_types", force: :cascade do |t|
    t.string "name", null: false
    t.integer "brand_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["brand_id"], name: "index_bead_types_on_brand_id"
  end

  create_table "beads", force: :cascade do |t|
    t.string "name", null: false
    t.string "brand_product_code", null: false
    t.json "metadata"
    t.integer "brand_id", null: false
    t.integer "size_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image"
    t.index ["brand_id"], name: "index_beads_on_brand_id"
    t.index ["size_id"], name: "index_beads_on_size_id"
  end

  add_foreign_key "bead_color_links", "bead_colors", column: "color_id"
  add_foreign_key "bead_color_links", "beads"
  add_foreign_key "bead_finish_links", "bead_finishes", column: "finish_id"
  add_foreign_key "bead_finish_links", "beads"
  add_foreign_key "bead_sizes.rb", "bead_brands", column: "brand_id"
  add_foreign_key "bead_sizes.rb", "bead_types", column: "type_id"
  add_foreign_key "bead_types", "bead_brands", column: "brand_id"
  add_foreign_key "beads", "bead_brands", column: "brand_id"
  add_foreign_key "beads", "bead_sizes.rb", column: "size_id"
end
