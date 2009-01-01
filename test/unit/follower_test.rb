require 'test_helper'

$twitter = {:user => 'unfollowme', :password => 'foo.bar'}

class FollowerTest < ActiveSupport::TestCase
  context "when fetching all followers" do
    setup do
      @base = Object.new
      Twitter::Base.stubs(:new).with('unfollowme', 'foo.bar').returns(@base)
      @myself = Twitter::User.new
      @base.stubs(:user).returns @myself
      
      @myself.followers_count = 300
      
      0.upto(2) do |number|
        followers = []
        100.times do |increment|
          user = Twitter::User.new
          user.id = number * 100 + increment
          followers << user
        end
        @base.expects(:followers).with(:page => number + 1).once.returns(followers)
      end
    end
    
    should "fetch all followers according to the profile" do
      assert_difference 'Follower.count', 300 do
        Follower.sync_with_twitter
      end
    end
  end
  
  context "when synchronizing followers" do
    setup do
      @base = Object.new
      Twitter::Base.stubs(:new).with('unfollowme', 'foo.bar').returns(@base)
      @user = Twitter::User.new
      @user.id = 100
      @user.name = 'Gonzo'
      @user.profile_image_url = 'http://img.twitter.com/noone.png'
      @base.stubs(:followers).returns [@user]
      @myself = Twitter::User.new
      @myself.followers_count = 1
      @base.stubs(:user).returns @myself
    end

    context "with nonexisting followers" do
      should "create non-existing followers" do
        assert_difference 'Follower.count', 1 do
          Follower.sync_with_twitter
        end
      end
    
      should "not create an existing follower" do
        Follower.create(:twitter_id => 100)
        assert_difference 'Follower.count', 0 do
          Follower.sync_with_twitter
        end
      end
    
      should "add the user data" do
        Follower.sync_with_twitter
        follower = Follower.first
        assert_equal 'Gonzo', follower.name
      end
    
      should "set the date on which the user started following" do
        Follower.sync_with_twitter
        assert_equal Date.today, Follower.first.started_following_on
      end
    end
    
    context "with existing followers" do
      context "when they stopped following earlier and started following again" do
        should "reset the stopped_following_on date" do
          follower = Follower.create(:twitter_id => 100, :stopped_following_on => Date.today)
          Follower.sync_with_twitter
          assert_equal nil, follower.reload.stopped_following_on
          assert_equal Date.today, follower.started_following_on
        end
      end
      
      context "when they stopped following" do
        should "set the stopped_following_on date" do
          follower = Follower.create(:twitter_id => 101)
          Follower.sync_with_twitter
          assert_equal Date.today, follower.reload.stopped_following_on
        end
      end
    end
  end
end
