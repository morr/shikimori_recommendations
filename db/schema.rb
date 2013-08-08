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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130723213900) do

  create_table "svds", :force => true do |t|
    t.binary   "entry_ids",  :limit => 16777215
    t.binary   "lsa",        :limit => 16777215
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
    t.string   "scale",                          :default => "full"
    t.string   "kind"
    t.binary   "user_ids",   :limit => 16777215
  end

  create_table "recommendation_ignores", :force => true do |t|
    t.integer "user_id"
    t.integer "target_id"
    t.string  "target_type"
  end

  add_index "recommendation_ignores", ["target_id", "target_type"], :name => "index_recommendation_ignores_on_target_id_and_target_type"
  add_index "recommendation_ignores", ["user_id", "target_id", "target_type"], :name => "index_recommendation_ignores_on_entry", :unique => true
  add_index "recommendation_ignores", ["user_id"], :name => "index_recommendation_ignores_on_user_id"

end
