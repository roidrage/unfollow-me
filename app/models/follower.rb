class Follower < ActiveRecord::Base
  named_scope :sorted, :order => ["started_following_on desc, stopped_following_on desc"]
  
  def self.sync_with_twitter
    TwitterSync.new.run
  end
  
  def update_data(twitter_user)
    update_attributes(:screen_name => twitter_user.screen_name, :name => twitter_user.name, :image_url => twitter_user.profile_image_url)
    update_attributes(:stopped_following_on => nil, :started_following_on => Date.today) if stopped_following_on?
  end
end
