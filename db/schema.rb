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

ActiveRecord::Schema.define(:version => 20120323030118) do

  create_table "comments", :force => true do |t|
    t.integer  "post_id"
    t.integer  "user_id"
    t.text     "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "comments", ["post_id"], :name => "index_comments_on_post_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "feeds", :force => true do |t|
    t.string   "title"
    t.string   "url"
    t.string   "feed_url"
    t.datetime "last_modified"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.boolean  "shared",        :default => false
  end

  add_index "feeds", ["shared"], :name => "index_feeds_on_shared"

  create_table "posts", :force => true do |t|
    t.integer  "feed_id"
    t.text     "title"
    t.string   "url"
    t.string   "author"
    t.text     "summary"
    t.text     "content"
    t.datetime "published"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.boolean  "shared",           :default => false
    t.integer  "original_post_id"
    t.text     "note"
  end

  add_index "posts", ["feed_id"], :name => "index_posts_on_feed_id"
  add_index "posts", ["shared"], :name => "index_posts_on_shared"

  create_table "reports", :force => true do |t|
    t.string   "report_type"
    t.text     "content"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "subscriptions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "feed_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "subscriptions", ["feed_id"], :name => "index_subscriptions_on_feed_id"
  add_index "subscriptions", ["user_id"], :name => "index_subscriptions_on_user_id"

  create_table "unreads", :force => true do |t|
    t.integer  "user_id"
    t.integer  "post_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.datetime "published"
  end

  add_index "unreads", ["post_id"], :name => "index_unreads_on_post_id"
  add_index "unreads", ["user_id"], :name => "index_unreads_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "share_token"
    t.string   "name"
    t.string   "instapaper_username"
    t.string   "instapaper_password"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
