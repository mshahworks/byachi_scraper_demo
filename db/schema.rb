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

ActiveRecord::Schema.define(version: 20140608104144) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "events", force: true do |t|
    t.string   "external_id"
    t.string   "event_name"
    t.text     "event_description"
    t.datetime "event_start_date"
    t.datetime "event_end_date"
    t.string   "event_location"
    t.string   "organizer_name"
    t.string   "organizer_email"
    t.string   "event_type"
    t.string   "event_url"
    t.string   "presenter"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
