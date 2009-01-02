class HomeController < ApplicationController
  def index
    @followers = Follower.sorted
  end
end
