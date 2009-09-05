class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.string :title ,:null => false
      t.text :body, :null => false
      t.text :body_html, :null => false
      t.string :status, :default => 'draft'
      t.datetime :published_at, :null => true
      t.boolean :approved
      t.integer :hits_count

      t.timestamps
    end
  end

  def self.down
    drop_table :articles
  end
end
