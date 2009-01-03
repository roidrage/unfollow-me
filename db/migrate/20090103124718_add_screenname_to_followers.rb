class AddScreennameToFollowers < ActiveRecord::Migration
  def self.up
    add_column :followers, :screen_name, :string
  end

  def self.down
    remove_column :followers, :screen_name
  end
end
