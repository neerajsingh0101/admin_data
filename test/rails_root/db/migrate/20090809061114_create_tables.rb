class CreateTables < ActiveRecord::Migration
  def self.up
    create_table(:articles, :primary_key => 'article_id') do |t|
      t.string :title ,:null => false
      t.text :body, :null => false
      t.text :body_html, :null => false
      t.string :status, :default => 'draft'
      t.datetime :published_at, :null => true
      t.boolean :approved
      t.integer :hits_count

      t.timestamps
    end

    create_table :comments do |t|
      t.integer :article_id, :null => false
      t.text :body, :null => false
      t.text :body_html, :null => false
      t.string :author_name, :null => false
      t.string :author_website, :null => true
      t.boolean :posted_by_admin, :default => false

      t.timestamps
    end

    create_table :cars do |t|
      t.integer :year
      t.string :brand
      t.timestamps
    end

    create_table :doors do |t|
      t.string :color
      t.integer :car_id
      t.timestamps
    end

    create_table :engines do |t|
      t.integer :cylinders
      t.integer :car_id
      t.timestamps
    end

  end

  def self.down
    drop_table :comments
    drop_table :articles
  end
end
