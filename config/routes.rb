Moviedb::Application.routes.draw do
  resources :movies
  resources :genres
  match 'movies/new', :controller => "movies", :action => "new"
  match 'movies/:id', :controller => 'movies', :action => 'show'
  match 'movies/', :controller => 'movies', :action => 'index'
end