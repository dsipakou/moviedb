require 'imdb_parser'
require 'kaminari'
require 'spreadsheet'

class MoviesController < ApplicationController

	def index
		set_filter
		clear_filter
		sorting
		@movies = Movie.filtering(session[:disknum], session[:search], session[:actor], session[:director], session[:year_from], session[:year_to], session[:imdb_from], session[:imdb_to], session[:sorting]).page(session[:page]).per(5)
		@count = Movie.filtering(session[:disknum], session[:search], session[:actor], session[:director], session[:year_from], session[:year_to], session[:imdb_from], session[:imdb_to], session[:sorting]).count
		if params[:xls]

		end
	end

	def new
		session[:movie_params] ||= {}
		@movie = Movie.new(session[:movie_params])
		@movie.build_movie_tech_detail
	end

	def edit
		@movie = Movie.find(params[:id])
	end

	def export
		export_xls
		@movie = Movie.find(params[:id])
		redirect_to @movie
	end

	def get_titles_from_imdb
		unless params[:movie][:imdb_link].empty?
			@imdb = IMDB.new(params[:movie][:imdb_link]) if params[:get_imdb_all] || params[:get_imdb_actors] || params[:imdb_upload] ||
															params[:get_imdb_orig_name] || params[:get_imdb_year] || params[:get_imdb_rating] ||
															params[:get_imdb_director] || params[:get_imdb_producer] || params[:get_imdb_composer] ||
															params[:get_imdb_stars] || params[:get_imdb_genre]

			params[:movie][:orig_name]	= @imdb.get_orig_name	if params[:get_imdb_all] || params[:get_imdb_orig_name]
			params[:movie][:year]		= @imdb.get_year		if params[:get_imdb_all] || params[:get_imdb_year]
			params[:movie][:imdb]		= @imdb.get_rating		if params[:get_imdb_all] || params[:get_imdb_rating]
			params[:movie][:director]	= @imdb.get_director	if params[:get_imdb_all] || params[:get_imdb_director]
			params[:movie][:produced]	= @imdb.get_producer	if params[:get_imdb_all] || params[:get_imdb_producer]
			params[:movie][:composer]	= @imdb.get_composer	if params[:get_imdb_all] || params[:get_imdb_composer]
			params[:movie][:stars]		= @imdb.get_stars		if params[:get_imdb_all] || params[:get_imdb_stars]
			params[:movie][:genre]		= @imdb.get_genre		if params[:get_imdb_all] || params[:get_imdb_genre]
			params[:movie][:actors]		= @imdb.get_actors		if params[:get_imdb_all] || params[:get_imdb_actors]
			params[:movie][:movie_tech_detail_attributes][:duration] = @imdb.get_duration if params[:get_imdb_all] || params[:get_imdb_duration]

			if params[:imdb_upload] || params[:get_imdb_all]
				params[:movie][:image_link] = @imdb.get_image if params[:movie][:image_link].empty?
				@image_link = params[:movie][:image_link]
			end
		end
	end

	def get_titles_from_kinopoisk
		if params[:get_kinopoisk_all] && !params[:movie][:kinopoisk_link].empty?
			@imdb = IMDB.new(params[:movie][:kinopoisk_link])
		end
	end

	def export_xls
		@movie = Movie.find(params[:id])
		book = Spreadsheet::Workbook.new
		sheet1 = book.create_worksheet
		sheet1.name = 'dvd'
		sheet1.row(0).concat %w{disknum name orig_name year genre director produced stars actors composer lang imdb_rating remarks desc imdb_link image_link duration file_size pic_size file_type screens}
		sheet1[1,0] = @movie.disknum
		sheet1[1,1] = @movie.name
		sheet1[1,2] = @movie.orig_name
		sheet1[1,3] = @movie.year
		sheet1[1,4] = @movie.genre
		sheet1[1,5] = @movie.director
		sheet1[1,6] = @movie.produced
		sheet1[1,7] = @movie.stars
		sheet1[1,8] = @movie.actors
		sheet1[1,9] = @movie.composer
		sheet1[1,10] = @movie.lang
		sheet1[1,11] = @movie.imdb
		sheet1[1,12] = @movie.remarks
		sheet1[1,13] = @movie.desc
		sheet1[1,14] = @movie.imdb_link
		sheet1[1,15] = @movie.image_link
		sheet1[1,16] = @movie.movie_tech_detail.duration
		sheet1[1,17] = @movie.movie_tech_detail.filesize
		sheet1[1,18] = @movie.movie_tech_detail.resolution
		sheet1[1,19] = @movie.movie_tech_detail.filetype
		sheet1[1,20] = @movie.movie_tech_detail.screenshots

		row = sheet1.row(1)
		book.write 'test-Worksheet.xls'
	end

	def create
		session[:order_params] = params[:movie] if params[:movie]
		get_titles_from_imdb
		get_titles_from_kinopoisk
		@movie = Movie.new(session[:order_params])
		respond_to do |format|
			if params[:movie_save]
				if @movie.save
					format.html { redirect_to @movie, notice: 'Movie was successfully created.' }
					format.json { render json: @movie, status: :created, location: @movie }
				else
					format.html { render action: "new" }
					format.json { render json: @movie.errors, status: :unprocessable_entity }
				end
			else
				@movie.errors.add(:imdb_link, "please") if params[:movie][:imdb_link].empty?
				format.html { render action: "new" }
			end
		end
	end

	def update
		@movie = Movie.find(params[:id])
		get_titles_from_imdb
		respond_to do |format|
			if params[:movie_save]
				if @movie.update_attributes(params[:movie])
					format.html { redirect_to @movie, notice: 'Movie was successfully updated.' }
					format.json { render json: @movie, status: :created, location: @movie }
				else
					format.html { render action: "edit" }
					format.json { render json: @movie.errors, status: :unprocessable_entity }
				end
			else
				@movie.errors.add(:imdb_link, "please") if params[:movie][:imdb_link].empty?
				if @movie.update_attributes(params[:movie])
					format.html { render action: "edit" }
				else
					format.html { render action: "edit"}
					format.json { render json: @movie.errors, status: :unprocessable_entity }
				end
			end
		end
	end

	def show
		@movie = Movie.find(params[:id])
	end

	def destroy
		@movie = Movie.find(params[:id])
		@movie.destroy
		respond_to do |format|
			format.html { redirect_to movies_url }
			format.json { head :no_content }
		end
	end

	def set_filter
		if params[:search]
			session[:search] = params[:search]
			session[:director] = nil;
			session[:actor] = nil
			session[:year_from] = nil
			session[:year_to] = nil
			session[:disknum] = nil
			session[:page] = 1
		elsif params[:year_from]
			session[:search] = nil
			session[:year_from] = Integer(params[:year_from])
			session[:year_to] = Integer(params[:year_to])
			if params[:imdb_from]
				session[:imdb_from] = Integer(params[:imdb_from])
				session[:imdb_to] = Integer(params[:imdb_to])
			end
			session[:page] = 1
		elsif params[:actor]
			session[:search] = nil
			session[:actor] = params[:actor]
			session[:page] = 1
		elsif params[:director]
			session[:search] = nil
			session[:director] = params[:director]
			session[:page] = 1
		elsif params[:disknum]
			session[:search] = nil
			session[:disknum] = params[:disknum]
			session[:page] = 1
		end
		if params[:page]
			session[:page] = params[:page]
		end
	end

	def clear_filter
		case params[:clear_filter]
		when "director"
			session[:director] = nil
			session[:page] = 1
		when "actor"
			session[:actor] = nil
			session[:page] = 1
		when "search"
			session[:search] = nil
			session[:page] = 1
		when "years"
			session[:year_from] = nil
			session[:year_to] = nil
			session[:page] = 1
		when "disknum"
			session[:disknum] = nil
			session[:page] = 1
		when "imdb"
			session[:imdb_from] = nil
			session[:imdb_to] = nil
			session[:page] = 1
		end
		redirect_to movies_url if params[:clear_filter]
	end

	def sorting
		case params[:sorting]
		when 'name'
			session[:sorting] =~ /name/ ? session[:sorting] = "name desc" : session[:sorting] = "name asc"
		when 'year'
			session[:sorting] =~ /year/ ? session[:sorting] = "year desc" : session[:sorting] = "year asc"
		when 'imdb'
			session[:sorting] =~ /imdb/ ? session[:sorting] = "imdb desc" : session[:sorting] = "imdb asc"
		end
	end
end