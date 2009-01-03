namespace :unfollow do
  desc "Run the synchronization"
  task :sync => :environment do
    Follower.sync_with_twitter
  end
end