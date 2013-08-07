require 'spreadsheet'

class Excel

	EXCEL_HEADER = %w{disknum name orig_name year genre director produced stars actors composer lang imdb_rating remarks desc imdb_link image_link duration file_size pic_size file_type screens}

	def initialize(movie)
		@movie = movie
	end

	def export_one
		book = Spreadsheet::Workbook.new
		sheet = book.create_worksheet
		movie_name = @movie.orig_name
		movie_name.gsub(/[^a-zA-Z0-9]/, '').empty? ? excel_file_name = "name_is_empty" : excel_file_name = movie_name.gsub(/[^a-zA-Z0-9]/, '')

		#sheet.name = 'dvd'
		sheet.row(0).concat EXCEL_HEADER
		sheet[1,0] = @movie.disknum
		sheet[1,1] = @movie.name
		sheet[1,2] = @movie.orig_name
		sheet[1,3] = @movie.year
		sheet[1,4] = @movie.genre
		sheet[1,5] = @movie.director
		sheet[1,6] = @movie.produced
		sheet[1,7] = @movie.stars
		sheet[1,8] = @movie.actors
		sheet[1,9] = @movie.composer
		sheet[1,10] = @movie.lang
		sheet[1,11] = @movie.imdb
		sheet[1,12] = @movie.remarks
		sheet[1,13] = @movie.desc
		sheet[1,14] = @movie.imdb_link
		sheet[1,15] = @movie.kinopoisk_link
		sheet[1,16] = @movie.image_link
		sheet[1,17] = @movie.movie_tech_detail.duration
		sheet[1,18] = @movie.movie_tech_detail.filesize
		sheet[1,19] = @movie.movie_tech_detail.resolution
		sheet[1,20] = @movie.movie_tech_detail.filetype
		sheet[1,21] = @movie.movie_tech_detail.screenshots

		row = sheet.row(1)
		#book.write "#{excel_file_name}.xls"
		send_data book
	end

	def export_many
		book = Spreadsheet::Workbook.new
		sheet = book.create_worksheet
		sheet.row(0).concat EXCEL_HEADER
		@movie.each_with_index do |movie, index|
			sheet[index,0] = movie.disknum
			sheet[index,1] = movie.name
			sheet[index,2] = movie.orig_name
			sheet[index,3] = movie.year
			sheet[index,4] = movie.genre
			sheet[index,5] = movie.director
			sheet[index,6] = movie.produced
			sheet[index,7] = movie.stars
			sheet[index,8] = movie.actors
			sheet[index,9] = movie.composer
			sheet[index,10] = movie.lang
			sheet[index,11] = movie.imdb
			sheet[index,12] = movie.remarks
			sheet[index,13] = movie.desc
			sheet[index,14] = movie.imdb_link
			sheet[index,15] = movie.kinopoisk_link
			sheet[index,16] = movie.image_link
			sheet[index,17] = movie.movie_tech_detail.duration
			sheet[index,18] = movie.movie_tech_detail.filesize
			sheet[index,19] = movie.movie_tech_detail.resolution
			sheet[index,20] = movie.movie_tech_detail.filetype
			sheet[index,21] = movie.movie_tech_detail.screenshots

			row = sheet.row(index)
		end
		book.write "many_records.xls"
	end
end