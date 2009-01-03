class Follower < ActiveRecord::Base
  named_scope :sorted, :order => ["started_following_on desc, stopped_following_on desc"]
  
  def self.sync_with_twitter
    followers = fetch_all_followers
    existing_followers = all
    
    synchronize_existing(existing_followers, followers)
    synchronize_followers(existing_followers, followers)
    logger.info("Successfully synchronized with Twitter at #{Time.now}")
  end
  
  def self.synchronize_existing(existing_followers, followers)
    existing_followers.each do |user|
      existing_follower = followers.find{|f| user.twitter_id == f.id.to_i}
      user.update_attributes(:stopped_following_on => Date.today) unless existing_follower || user.stopped_following_on?
    end
  end
  
  def self.synchronize_followers(existing_followers, followers)
    followers.each do |follower|
      existing_follower = existing_followers.find {|user| user.twitter_id == follower.id.to_i}
      if existing_follower
        existing_follower.update_data(follower)
      else
        create(:name => follower.name, :screen_name => follower.screen_name, :image_url => follower.profile_image_url, :twitter_id => follower.id, :started_following_on => Date.today)
      end
    end
  end
  
  def self.fetch_all_followers
    twitter = Twitter::Base.new($twitter[:user], $twitter[:password])
    followers_count = twitter.user($twitter[:user]).followers_count.to_i
    all_followers(twitter, followers_count)
  end

  def self.all_followers(twitter, followers_count)
    followers = []
    page = 1
    while followers.size < followers_count
      next_page(twitter, followers, page)
      page += 1
    end
    followers
  end  

  def self.next_page(twitter, followers, page)
    followers << twitter.followers(:page => page)
    followers.flatten!
  end
  
  def update_data(twitter_user)
    update_attributes(:screen_name => twitter_user.screen_name, :name => twitter_user.name, :image_url => twitter_user.profile_image_url)
    update_attributes(:stopped_following_on => nil, :started_following_on => Date.today) if stopped_following_on?
  end
end
