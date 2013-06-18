require 'imdb_parser'
require 'kinopoisk_parser'
require 'excel_ops'
require 'file_ops'
require 'kaminari'


class MoviesController < ApplicationController

	def index
		set_filter
		clear_filter
		sorting
		@movies = Movie.filtering(session[:disknum], session[:search], session[:actor], session[:director], session[:year_from], session[:year_to], session[:imdb_from], session[:imdb_to], session[:genre_inc], session[:genre_exc], session[:sorting]).page(params[:page]).per(5)
		@count = Movie.filtering(session[:disknum], session[:search], session[:actor], session[:director], session[:year_from], session[:year_to], session[:imdb_from], session[:imdb_to], session[:genre_inc], session[:genre_exc], session[:sorting]).count
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
		@movie = Movie.find(params[:id])
		@excel = Excel.new(@movie)
		@excel.export_one

		redirect_to @movie
	end

	def export_many
		@movies = Movie.filtering(session[:disknum], session[:search], session[:actor], session[:director], session[:year_from], session[:year_to], session[:imdb_from], session[:imdb_to], session[:genre_inc], session[:genre_exc], session[:sorting])
		@excel = Excel.new(@movies)
		@excel.export_many

		redirect_to movies_url
	end

	def get_titles_from_imdb
		unless params[:movie][:imdb_link].empty?
			@imdb = IMDB.new(params[:movie][:imdb_link]) if params[:get_imdb_all] || params[:get_imdb_actors] || params[:imdb_upload] ||
															params[:get_imdb_orig_name] || params[:get_imdb_year] || params[:get_imdb_rating] ||
															params[:get_imdb_director] || params[:get_imdb_producer] || params[:get_imdb_composer] ||
															params[:get_imdb_stars] || params[:get_imdb_genre] || params[:get_imdb_duration]

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
		if params[:url_upload_button] && !params[:url_upload_textbox].empty?
			@file_ops = FileOps.new()
			params[:movie][:image_link] = @file_ops.get_image_from_url(params[:url_upload_textbox])
			@image_link = params[:movie][:image_link]
		end
	end

	def get_titles_from_kinopoisk
		if params[:get_kinopoisk_all] && !params[:movie][:kinopoisk_link].empty?
			@kinopoisk = Kinopoisk.new(params[:movie][:kinopoisk_link])
			@rating = @kinopoisk.get_rating
		end
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
		get_titles_from_kinopoisk
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
			session[:director], session[:actor], session[:year_from], session[:year_to], session[:disknum], session[:imdb_from], session[:imdb_to], session[:genre_inc], session[:genre_exc] = nil;
		elsif params[:years]
			session[:search] = nil
			session[:genre_inc] = nil
			session[:genre_exc] = nil
			session[:year_from] = Integer(params[:years].split(';')[0])
			session[:year_to] = Integer(params[:years].split(';')[1])
			if params[:imdb]
				session[:imdb_from] = Integer(params[:imdb].split(';')[0])
				session[:imdb_to] = Integer(params[:imdb].split(';')[1])
			end
			session[:genre_inc] = params[:genre_inc] if params[:genre_inc]
			session[:genre_exc] = params[:genre_exc] if params[:genre_exc]
		elsif params[:actor]
			session[:search] = nil
			session[:actor] = params[:actor]
		elsif params[:director]
			session[:search] = nil
			session[:director] = params[:director]
		elsif params[:disknum]
			session[:search] = nil
			session[:disknum] = params[:disknum]
		end
	end

	def clear_filter
		case params[:clear_filter]
		when "director"
			session[:director] = nil
		when "actor"
			session[:actor] = nil
		when "search"
			session[:search] = nil
		when "years"
			session[:year_from] = nil
			session[:year_to] = nil
		when "disknum"
			session[:disknum] = nil
		when "imdb"
			session[:imdb_from] = nil
			session[:imdb_to] = nil
		end
		redirect_to movies_url if params[:clear_filter]
	end

	def sorting
		case params[:sorting]
		when 'name'
			session[:sorting] =~ /name/ ? session[:sorting] =~ /desc/ ? session[:sorting] = "name asc" : session[:sorting] = "name desc" : session[:sorting] = "name asc"
		when 'year'
			session[:sorting] =~ /year/ ? session[:sorting] =~ /desc/ ? session[:sorting] = "year asc" : session[:sorting] = "year desc" : session[:sorting] = "year asc"
		when 'imdb'
			session[:sorting] =~ /imdb/ ? session[:sorting] =~ /desc/ ? session[:sorting] = "imdb asc" : session[:sorting] = "imdb desc" : session[:sorting] = "imdb asc"
		end
	end
end