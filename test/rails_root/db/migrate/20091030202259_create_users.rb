class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.integer :age
      t.text :data
      t.boolean :active, :default => false 
      t.text    :description
      t.datetime :born_at

      t.timestamps
    end

    create_table :phone_numbers do |t|
      t.string :number
      t.integer :user_id

      t.timestamps
    end

    create_table :websites do |t|
      t.string :url
      t.integer :user_id

      t.timestamps
    end

    create_table :clubs do |t|
      t.string :name
    end
    create_table :clubs_users, :id => false do |t|
      t.integer :user_id, :null => false
      t.integer :club_id, :null => false
    end

  end

  def self.down
    drop_table :users
  end
end
