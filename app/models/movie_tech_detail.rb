class MovieTechDetail < ActiveRecord::Base
	belongs_to :movie

	attr_accessible :movie_id,
					:duration,
					:filesize,
					:filetype,
					:movie_id,
					:resolution,
					:screenshots
end
