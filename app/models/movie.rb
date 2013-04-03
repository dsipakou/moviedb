class Movie < ActiveRecord::Base

	attr_accessible :actors,
					:composer,
					:desc,
					:director,
					:disknum,
					:genre,
					:image_link,
					:imdb,
					:imdb_link,
					:kinopoisk_link,
					:lang,
					:name,
					:orig_name,
					:produced,
					:remarks,
					:stars,
					:year,
					:movie_tech_detail_attributes

	has_one :movie_tech_detail, :dependent => :destroy
	accepts_nested_attributes_for :movie_tech_detail

	validates_presence_of :name, :message => "please"
	validates_numericality_of :year, :imdb, message: " should be a number :("

	def self.filtering(disknum, search, actor, director, year_from, year_to, imdb_from, imdb_to, sorting)
		query = ""
		if search
			query += "disknum LIKE '%#{search}%' or name LIKE '%#{search}%' or orig_name LIKE '%#{search}%'or director LIKE '#{search}' or stars LIKE '#{search}'"
		end
		if disknum
			query += "AND " unless query.empty?
			query += "disknum LIKE '%#{disknum}%' "
		end
		if actor
			query += "AND " unless query.empty?
			query += "(stars LIKE '%#{actor}%' OR actors LIKE '%#{actor}%') "
		end
		if director
			query += "AND " unless query.empty?
			query += "director LIKE '%#{director}%' "
		end
		if year_from
			query += "AND " unless query.empty?
			query += "(year >= #{year_from} AND year <= #{year_to}) "
		end
		if imdb_from
			imdb_from = Integer(imdb_from) * 10
			imdb_to = Integer(imdb_to) * 10
			query += "AND " unless query.empty?
			query += "(imdb >= #{imdb_from} AND imdb <= #{imdb_to})"
		end
		if (query.empty?)
			sorting ? Movie.order(sorting) : Movie.order("name desc")
		else
			sorting ? Movie.where(query).order(sorting) : Movie.where(query).order("name desc")
		end
	end
end
