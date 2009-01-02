# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def next_date(follower)
    if new_date?(follower)
      @__current_date = follower.stopped_following_on? ? follower.stopped_following_on : follower.started_following_on
    else
      ""
    end
  end
  
  def new_date?(follower)
    @__current_date ||= Date.today + 1.day
    @__current_date > follower.started_following_on or
      (follower.stopped_following_on? and @__current_date > follower.stopped_following_on)
  end
end
