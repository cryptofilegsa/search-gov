# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090916135047) do

  create_table "affiliates", :force => true do |t|
    t.string   "name",       :null => false
    t.text     "domains"
    t.text     "header"
    t.text     "footer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "affiliates", ["name"], :name => "index_affiliates_on_name", :unique => true

  create_table "daily_query_ip_stats", :force => true do |t|
    t.date    "day",                   :null => false
    t.string  "query",  :limit => 100, :null => false
    t.string  "ipaddr", :limit => 17,  :null => false
    t.integer "times",                 :null => false
  end

  add_index "daily_query_ip_stats", ["query"], :name => "index_daily_query_ip_stats_on_query"

  create_table "daily_query_stats", :force => true do |t|
    t.date    "day",                  :null => false
    t.string  "query", :limit => 100, :null => false
    t.integer "times",                :null => false
  end

  add_index "daily_query_stats", ["day", "query"], :name => "index_daily_query_stats_on_day_and_query", :unique => true
  add_index "daily_query_stats", ["query", "day"], :name => "index_daily_query_stats_on_query_and_day"

  create_table "queries", :id => false, :force => true do |t|
    t.string    "ipaddr",    :limit => 17
    t.string    "query",     :limit => 100
    t.string    "affiliate", :limit => 32
    t.integer   "epoch"
    t.string    "wday",      :limit => 3
    t.string    "month",     :limit => 3
    t.integer   "day"
    t.time      "time_col"
    t.string    "tz",        :limit => 5
    t.integer   "year"
    t.timestamp "timestamp",                :null => false
  end

  add_index "queries", ["query"], :name => "queryindex"
  add_index "queries", ["timestamp"], :name => "timestamp"

  create_table "query_accelerations", :force => true do |t|
    t.date    "day",                        :null => false
    t.integer "window_size",                :null => false
    t.string  "query",       :limit => 100, :null => false
    t.float   "score",                      :null => false
  end

  add_index "query_accelerations", ["day", "window_size", "score"], :name => "index_query_accelerations_on_day_and_window_size_and_score"

  create_table "temp_window_counts", :id => false, :force => true do |t|
    t.string  "query",  :limit => 100
    t.integer "period"
    t.integer "count"
  end

  add_index "temp_window_counts", ["period"], :name => "period"

end
