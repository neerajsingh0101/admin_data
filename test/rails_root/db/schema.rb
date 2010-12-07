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

ActiveRecord::Schema.define(:version => 20091030202259) do

  create_table "cities", :force => true do |t|
    t.string   "name"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "clubs", :force => true do |t|
    t.string "name"
  end

  create_table "clubs_users", :id => false, :force => true do |t|
    t.integer "user_id", :null => false
    t.integer "club_id", :null => false
  end

  create_table "papers", :id => false, :force => true do |t|
    t.string "paper_id", :null => false
    t.string "name"
  end

  create_table "phone_numbers", :force => true do |t|
    t.string   "number"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "age"
    t.text     "data"
    t.boolean  "active",      :default => false
    t.text     "description"
    t.datetime "born_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "websites", :force => true do |t|
    t.string   "url"
    t.integer  "user_id"
    t.string   "dns_provider", :default => "yahoo"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
