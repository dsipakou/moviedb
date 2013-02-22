class MoviesController < ApplicationController
  def index
    @movies = Movie.find(:all)
    @year_min = Movie.minimum(:year)
    @year_max = Movie.maximum(:year)
    @years_sorted = Movie.find(:all, :order => 'year DESC', :conditions => 'year > 1900')
  end
  def toolbox
    
  end
  def new
    @movie = Movie.new
  end
  def create
    @movie = Movie.new(params[:movie])
    @movie.save
    redirect_to "/movies/#{@movie.id}"
  end
  def show
    @movie = Movie.find(params[:id])
  end
end
