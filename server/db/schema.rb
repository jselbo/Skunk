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

ActiveRecord::Schema.define(version: 20150923224430) do

  create_table "sessions", force: :cascade do |t|
    t.integer  "sharer_id",        limit: 4
    t.boolean  "needs_driver"
    t.integer  "driver_id",        limit: 4
    t.datetime "start_time"
    t.boolean  "is_time_based"
    t.datetime "end_time"
    t.text     "destination",      limit: 65535
    t.boolean  "terminated"
    t.datetime "last_updated"
    t.boolean  "requested_pickup"
    t.datetime "driver_eta"
  end

  create_table "sessions_users", force: :cascade do |t|
    t.integer "session_id",     limit: 4
    t.integer "receiver_id",    limit: 4
    t.boolean "sharer_ended"
    t.boolean "receiver_ended"
  end

  create_table "users", force: :cascade do |t|
    t.string "name",  limit: 255
    t.string "email", limit: 255
  end

end
