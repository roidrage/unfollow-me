class TwitterSync
  attr_accessor :logger, :followers, :existing_followers
  
  def initialize
    @logger = RAILS_DEFAULT_LOGGER
  end
  
  def run
    fetch_all_followers
    self.existing_followers = Follower.all
    
    synchronize_existing
    synchronize_followers
    logger.info("Successfully synchronized with Twitter at #{Time.now}")
  end
  
  def synchronize_existing
    existing_followers.each do |user|
      existing_follower = followers.find{|f| user.twitter_id == f.id.to_i}
      user.update_attributes(:stopped_following_on => Date.today) unless existing_follower || user.stopped_following_on?
    end
  end
  
  def synchronize_followers
    followers.each do |follower|
      existing_follower = existing_followers.find {|user| user.twitter_id == follower.id.to_i}
      if existing_follower
        existing_follower.update_data(follower)
      else
        Follower.create(:name => follower.name, :screen_name => follower.screen_name, :image_url => follower.profile_image_url, :twitter_id => follower.id, :started_following_on => Date.today)
      end
    end
  end
  
  def fetch_all_followers
    @followers_count = twitter.user($twitter[:user]).followers_count.to_i
    all_followers
  end

  def all_followers
    @followers = []
    page = 1
    while @followers.size < @followers_count
      next_page(page)
      page += 1
    end
  end  

  def next_page(page)
    followers << twitter.followers(:page => page)
    followers.flatten!
  end
  
  def twitter
    @twitter ||= Twitter::Base.new($twitter[:user], $twitter[:password])
  end
end