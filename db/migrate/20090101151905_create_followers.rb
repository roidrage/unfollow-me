class CreateFollowers < ActiveRecord::Migration
  def self.up
    create_table :followers do |t|
      t.string :name
      t.string :image_url
      t.date :stopped_following_on
      t.date :started_following_on
      t.integer :twitter_id

      t.timestamps
    end
  end

  def self.down
    drop_table :followers
  end
end
