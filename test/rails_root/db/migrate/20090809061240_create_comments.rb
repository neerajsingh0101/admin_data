class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer :article_id, :null => false
      t.text :body, :null => false
      t.text :body_html, :null => false
      t.string :author_name, :null => false
      t.string :author_website, :null => true
      t.boolean :posted_by_admin, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
