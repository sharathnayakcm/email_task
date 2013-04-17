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

ActiveRecord::Schema.define(:version => 20130214133925) do

  create_table "beehive_views", :force => true do |t|
    t.integer  "owner_id"
    t.string   "view_name",                                                                :null => false
    t.string   "view_type"
    t.enum     "view_for",          :limit => [:channel, :cug, :adhoc]
    t.datetime "created_at",                                                               :null => false
    t.datetime "updated_at",                                                               :null => false
    t.string   "ancestry"
    t.string   "view_scope"
    t.boolean  "show_insync",                                           :default => false
    t.string   "parametrized_link"
  end

  add_index "beehive_views", ["ancestry"], :name => "index_beehive_views_on_ancestry"

  create_table "buzz_flags", :force => true do |t|
    t.integer  "buzz_id"
    t.integer  "flag_id"
    t.integer  "user_id"
    t.date     "expiry_date"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "buzz_insyncs", :force => true do |t|
    t.integer  "channel_id"
    t.integer  "buzz_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "buzz_members", :force => true do |t|
    t.integer  "user_id"
    t.integer  "buzz_id"
    t.integer  "channel_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "buzz_names", :force => true do |t|
    t.integer  "buzz_id"
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "buzz_tags", :force => true do |t|
    t.integer  "buzz_id"
    t.integer  "tag_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "buzz_tasks", :force => true do |t|
    t.integer  "user_id",                                                         :null => false
    t.integer  "buzz_id",                                                         :null => false
    t.string   "name",       :limit => 100
    t.date     "due_date"
    t.enum     "priority",   :limit => [:high, :medium, :low]
    t.boolean  "status",                                       :default => false, :null => false
    t.datetime "created_at",                                                      :null => false
    t.datetime "updated_at",                                                      :null => false
  end

  create_table "buzzs", :force => true do |t|
    t.text     "message"
    t.integer  "channel_id"
    t.integer  "user_id"
    t.boolean  "priority"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "attachment"
    t.string   "ancestry"
  end

  add_index "buzzs", ["ancestry"], :name => "index_buzzs_on_ancestry"

  create_table "channel_aliases", :force => true do |t|
    t.string   "name"
    t.integer  "channel_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "channel_associations", :force => true do |t|
    t.integer  "channel_id"
    t.integer  "cug_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "channels", :force => true do |t|
    t.string   "name"
    t.boolean  "is_cug",               :default => false
    t.integer  "user_id"
    t.boolean  "is_active",            :default => true
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.text     "description"
    t.date     "last_buzz_created_at"
  end

  create_table "flags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "mailman_loggers", :force => true do |t|
    t.string   "sender"
    t.string   "subject"
    t.text     "message"
    t.text     "response"
    t.string   "status"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "priority_buzzs", :force => true do |t|
    t.integer  "buzz_id"
    t.integer  "user_id"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "owner_id"
    t.boolean  "insync",     :default => false
  end

  create_table "response_expected_buzzs", :force => true do |t|
    t.integer  "buzz_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "owner_id"
  end

  create_table "settings", :force => true do |t|
    t.text     "company_info"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "subscriptions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "channel_id"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.datetime "last_viewed"
    t.boolean  "is_core",     :default => true
  end

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.integer  "channel_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "user_preferences", :force => true do |t|
    t.integer  "user_id"
    t.string   "buzz_rate_1"
    t.string   "buzz_rate_2"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.string   "cug_view"
    t.string   "channel_view"
    t.string   "tooltip_view", :default => "long"
  end

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.boolean  "is_admin",                              :default => false
    t.boolean  "is_active",                             :default => true
    t.string   "email",                                 :default => "",    :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "authentication_token"
    t.datetime "created_at",                                               :null => false
    t.datetime "updated_at",                                               :null => false
    t.string   "display_name"
    t.string   "dozz_email"
    t.string   "remember_token"
    t.string   "cug_view",                              :default => "pv"
    t.integer  "dormant_days",                          :default => 2
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "watch_channels", :force => true do |t|
    t.integer  "channel_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
