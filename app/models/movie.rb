class Movie < ActiveRecord::Base
  attr_accessible :actors, :composer, :desc, :director, :disknum, :genre, :image_link, :imdb, :imdb_link, :kinopoisk_link, :imdbhtml1, :imdbhtml2, :lang, :name, :orig_name, :produced, :remarks, :stars, :year
end
