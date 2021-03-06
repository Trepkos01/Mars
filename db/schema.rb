# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160617161303) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "comments_responses", force: :cascade do |t|
    t.boolean  "helpful",                null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "meal_recommendation_id"
    t.string   "user_id"
  end

  add_index "comments_responses", ["meal_recommendation_id"], name: "index_comments_responses_on_meal_recommendation_id", using: :btree
  add_index "comments_responses", ["user_id"], name: "index_comments_responses_on_user_id", using: :btree

  create_table "identities", force: :cascade do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "user_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "access_token"
    t.string   "access_secret"
  end

  add_index "identities", ["user_id"], name: "index_identities_on_user_id", using: :btree

  create_table "issues", force: :cascade do |t|
    t.text     "issue",                      null: false
    t.string   "user_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "resolved",   default: false
  end

  add_index "issues", ["user_id"], name: "index_issues_on_user_id", using: :btree

  create_table "meal_additionals", force: :cascade do |t|
    t.float    "cost",       default: 0.5, null: false
    t.float    "portion",    default: 0.5, null: false
    t.string   "user_agent",               null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "meal_id"
    t.string   "user_id"
  end

  add_index "meal_additionals", ["meal_id"], name: "index_meal_additionals_on_meal_id", using: :btree
  add_index "meal_additionals", ["user_id"], name: "index_meal_additionals_on_user_id", using: :btree

  create_table "meal_recommendations", force: :cascade do |t|
    t.boolean  "rating",                     null: false
    t.string   "user_agent",                 null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "meal_id"
    t.string   "user_id"
    t.boolean  "shared",     default: false, null: false
    t.text     "comments"
  end

  add_index "meal_recommendations", ["meal_id"], name: "index_meal_recommendations_on_meal_id", using: :btree
  add_index "meal_recommendations", ["user_id"], name: "index_meal_recommendations_on_user_id", using: :btree

  create_table "meals", force: :cascade do |t|
    t.string   "meal_name",     default: "",    null: false
    t.text     "description",   default: "",    null: false
    t.boolean  "active",        default: false, null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "user_id"
    t.string   "restaurant_id"
    t.string   "category"
    t.string   "image"
  end

  add_index "meals", ["restaurant_id"], name: "index_meals_on_restaurant_id", using: :btree
  add_index "meals", ["user_id"], name: "index_meals_on_user_id", using: :btree

  create_table "restaurants", force: :cascade do |t|
    t.string   "restaurant_name", default: "",    null: false
    t.string   "address",         default: "",    null: false
    t.float    "lat",             default: 0.0,   null: false
    t.float    "lng",             default: 0.0,   null: false
    t.boolean  "active",          default: false, null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "user_id"
    t.string   "image"
  end

  add_index "restaurants", ["user_id"], name: "index_restaurants_on_user_id", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.string   "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "user_name",              default: "",        null: false
    t.string   "email",                  default: "",        null: false
    t.string   "encrypted_password",     default: "",        null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,         null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,         null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.boolean  "moderator",              default: false
    t.datetime "deleted_at"
    t.string   "provider",               default: "default", null: false
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

end
