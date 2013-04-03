Moviedb::Application.routes.draw do
	resources :movies
	resources :genres

	match 'export/:id', :controller => "movies", :action => "export"
	match 'export_many', :controller => "movies", :action => "export_many"
	match 'movies/new', :controller => "movies", :action => "new"
	match 'movies/:id', :controller => 'movies', :action => 'show'
	match 'movies/', :controller => 'movies', :action => 'index'
	match 'movies/:id/edit/', :controller => "movies", :action => "edit"
end