class Follower < ActiveRecord::Base
  named_scope :sorted, :order => ["started_following_on desc, stopped_following_on desc"]
  
  def self.sync_with_twitter
    followers = fetch_all_followers
    existing_followers = all
    
    existing_followers.each do |user|
      existing_follower = followers.find{|f| user.twitter_id == f.id.to_i}
      user.update_attributes(:stopped_following_on => Date.today) unless existing_follower || user.stopped_following_on?
    end
    
    followers.each do |follower|
      existing_follower = existing_followers.find {|user| user.twitter_id == follower.id.to_i}
      if existing_follower
        existing_follower.update_attributes(:screen_name => follower.screen_name, :name => follower.name, :image_url => follower.profile_image_url)
        existing_follower.update_attributes(:stopped_following_on => nil, :started_following_on => Date.today) if existing_follower.stopped_following_on?
      else
        create(:name => follower.name, :screen_name => follower.screen_name, :image_url => follower.profile_image_url, :twitter_id => follower.id, :started_following_on => Date.today)
      end
    end
    
    logger.info("Successfully synchronized with Twitter at #{Time.now}")
  end
  
  def self.fetch_all_followers
    twitter = Twitter::Base.new($twitter[:user], $twitter[:password])
    followers_count = twitter.user($twitter[:user]).followers_count.to_i
    followers = []
    page = 1
    until followers.size >= followers_count
      followers << twitter.followers(:page => page)
      followers.flatten!
      page += 1
    end
    followers
  end
end
