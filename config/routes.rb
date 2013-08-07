Moviedb::Application.routes.draw do
	resources :movies
	resources :genres

	root to: 'movies#index', as: :main
	match 'export/:id', to: "movies#export"
	match 'export_many', to: "movies#export_many"
	match 'movies/new', to: "movies#new"
	match 'movies/:id', to: 'movies#show'
	match 'movies/', to: 'movies#index'
	match 'movies/:id/edit/', to: "movies#edit"
end