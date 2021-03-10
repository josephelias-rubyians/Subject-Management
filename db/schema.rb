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

ActiveRecord::Schema.define(version: 2021_03_10_033241) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "sub_and_classes", force: :cascade do |t|
    t.bigint "subject_id", null: false
    t.bigint "teaching_class_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["subject_id"], name: "index_sub_and_classes_on_subject_id"
    t.index ["teaching_class_id"], name: "index_sub_and_classes_on_teaching_class_id"
  end

  create_table "subjects", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "teaching_classes", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "user_and_subjects", force: :cascade do |t|
    t.bigint "subject_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["subject_id"], name: "index_user_and_subjects_on_subject_id"
    t.index ["user_id"], name: "index_user_and_subjects_on_user_id"
  end

  create_table "user_classes_subjects", force: :cascade do |t|
    t.bigint "subject_id", null: false
    t.bigint "teaching_class_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["subject_id"], name: "index_user_classes_subjects_on_subject_id"
    t.index ["teaching_class_id"], name: "index_user_classes_subjects_on_teaching_class_id"
    t.index ["user_id"], name: "index_user_classes_subjects_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password"
    t.boolean "admin"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "sub_and_classes", "subjects"
  add_foreign_key "sub_and_classes", "teaching_classes"
  add_foreign_key "user_and_subjects", "subjects"
  add_foreign_key "user_and_subjects", "users"
  add_foreign_key "user_classes_subjects", "subjects"
  add_foreign_key "user_classes_subjects", "teaching_classes"
  add_foreign_key "user_classes_subjects", "users"
end
