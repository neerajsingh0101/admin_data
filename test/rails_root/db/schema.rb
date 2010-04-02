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

ActiveRecord::Schema.define(:version => 20090809061114) do

  create_table "articles", :primary_key => "article_id", :force => true do |t|
    t.string   "title",                              :null => false, :limit => 200
    t.text     "body",                               :null => false
    t.text     "body_html",                          :null => false
    t.text     "short_desc"
    t.string   "status",        :default => "draft", :limit => 50
    t.datetime "published_at"
    t.boolean  "approved"
    t.integer  "hits_count"
    t.string   "magazine_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "magazine_id"
    t.text     "data"
  end

  create_table "cars", :force => true do |t|
    t.integer  "year"
    t.string   "brand"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cities", :force => true do |t|
    t.string   "name"
    t.string   "permanent_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.integer  "article_id",                         :null => false
    t.text     "body",                               :null => false
    t.text     "body_html",                          :null => false
    t.string   "author_name",                        :null => false
    t.string   "author_website"
    t.boolean  "posted_by_admin", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "doors", :force => true do |t|
    t.string   "color"
    t.integer  "car_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "engines", :force => true do |t|
    t.integer  "cylinders"
    t.integer  "car_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tech_magazines", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
