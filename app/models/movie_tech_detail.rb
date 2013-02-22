class MovieTechDetail < ActiveRecord::Base
  attr_accessible :duration, :filesize, :filetype, :movie_id, :resolution, :screenshots
  belongs_to :movie
end
