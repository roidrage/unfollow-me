ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/:action/:id'
  map.connect '', :controller => "home"
end
