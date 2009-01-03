class HomeController < ApplicationController
  def index
    @followers = Follower.sorted.paginate(:per_page => 50, :page => params[:page])
  end
end
