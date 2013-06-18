module MoviesHelper
	### Index page block ###
	# Get title for movie index page like: "1-5 of 67"
	def items_on_the_page_label(total)
		label = if params[:page]
			((Integer(params[:page]) - 1) * 5 + 1).to_s
		else
			"1"
		end
		label += " - "
		label += if params[:page]
			if Integer(params[:page]) * 5 > total
				total.to_s
			else
				(Integer(params[:page]) * 5).to_s
			end
		else
			if total > 5
				"5"
			else
				total.to_s
			end
		end
		label
	end

	def genre_checkbox(type, value)
		genre_array = session[:genre_inc]
		genre_array = session[:genre_exc] if type.eql?("exc")
		selected = false
		selected = true if genre_array && genre_array.find_index("#{value}")
		check_box_tag "genre_#{type}[]", value, selected
	end

	### End of index page block ###

	### Start of show page block ###
	def duration(movie)

		unless movie.movie_tech_detail.duration.empty?
			hours = Integer(movie.movie_tech_detail.duration) / 60
			mins = Integer(movie.movie_tech_detail.duration) - (Integer(movie.movie_tech_detail.duration) / 60) * 60
			mins = "0#{mins}" if mins < 10
			"#{hours}:#{mins}"
		end
	end
	### End of show page block ###
end
