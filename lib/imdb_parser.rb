require 'nokogiri'
require 'open-uri'

class IMDB

	attr_reader :image_name

	POSTER_XPATH			= "//div[@class='image']/a[contains(@href, 'media')]/img[@itemprop='image']"
	DIRECTOR_XPATH			= "//a[text()='Directed by']/../../../..//a[contains(@href, 'name')]"
	DIRECTOR_SERIES_XPATH	= "//a[text()='Series Directed by']/../../../..//a[contains(@href, 'name')]"
	STARS_XPATH				= "//div[@itemprop='actors']/a/span[@class='itemprop']"
	ACTORS_XPATH			= "//table[@class='cast_list']//td[@itemprop='actor']/a[contains(@href, 'name')]/span[@itemprop='name']"
	ACTORS_SERIES_XPATH		= "//table[@class='cast']//td[@class='nm']/a[contains(@href, 'name')]"
	PRODUCER_XPATH			= "//a[text()='Produced by']/../../../..//a[contains(@href, 'name')]"
	PRODUCER_SERIES_XPATH	= "//a[text()='Series Produced by']/../../../..//a[contains(@href, 'name')]"
	COMPOSER_XPATH			= "//a[text()='Original Music by']/../../../..//a[contains(@href, 'name')]"
	COMPOSER_SERIES_XPATH	= "//a[text()='Series Original Music by']/../../../..//a[contains(@href, 'name')]"
	GENRE_XPATH				= "//div[@itemprop='genre']/a"
	GENRE_ALT_XPATH			= "//a[contains(@href, 'genre')]/span[@itemprop='genre']"
	RATING_XPATH			= "//div[@class='star-box giga-star']/div[@class='titlePageSprite star-box-giga-star']"
	YEAR_XPATH				= "//h1[@class='header']//a[contains(@href, 'year')]"
	YEAR_ALT_XPATH			= "//div[contains(@id, 'title')]//span/a[contains(@href, 'year')]"
	ORIG_NAME_XPATH			= "//h1[@class='header']/span[@itemprop='name']"
	DURATION_XPATH			= "//h3[text() = 'Technical Specs']/../div/time[@itemprop='duration']"

	IMAGE_SAVE_PATH			= "app/assets/images/posters/"
	IMAGE_DB_PATH			= "posters/"

	def initialize(url)
		@url = url
		@main_page = get_page(@url)
		@cast_page = get_cast_page(@url)
		@rus_page = get_rus_page(@url)
	end

	private
	def get_page(url)
		Nokogiri::HTML(open(url))
	end

	def get_rus_page(url)
		Nokogiri::HTML(open(url), nil, 'Windows-1251')
	end

	def get_cast_page(url)
		url.last == "/" ? get_page("#{url}fullcredits") : get_page("#{url}/fullcredits")
	end

	def get_items(page, xpath)
		items = Array.new
		page.xpath(xpath).each do |item|
			items << item
		end
		items.empty? ? nil : items.join(", ").squish
	end

	def get_first_item(page, xpath)
		String(page.xpath(xpath).first)
	end

	public
	def get_stars
		get_items(@main_page, STARS_XPATH)
	end

	def get_actors
		get_items(@main_page, ACTORS_XPATH) || get_items(@cast_page, ACTORS_SERIES_XPATH)
	end

	def get_director
		get_items(@cast_page, DIRECTOR_XPATH) || get_items(@cast_page, DIRECTOR_SERIES_XPATH)
	end

	def get_producer
		get_items(@cast_page, PRODUCER_XPATH) || get_items(@cast_page, PRODUCER_SERIES_XPATH)
	end

	def get_composer
		get_items(@cast_page, COMPOSER_XPATH) || get_items(@cast_page, COMPOSER_SERIES_XPATH)
	end

	def get_genre
		get_items(@main_page, GENRE_XPATH) || get_items(@main_page, GENRE_ALT_XPATH)
	end

	def get_rating
		rating = get_items(@main_page, RATING_XPATH)
		Integer(rating.tr(",.", "")) if rating
	end

	def get_year
		year = get_items(@main_page, YEAR_XPATH) || get_items(@cast_page, YEAR_ALT_XPATH)
		Integer(year) if year
	end

	def get_orig_name
		get_items(@main_page, ORIG_NAME_XPATH)
	end

	def get_duration
		duration = get_first_item(@main_page, DURATION_XPATH)
		duration.tr(" min", "") if duration
	end

	def get_image
		node = @main_page.xpath(POSTER_XPATH).first
		src = node.attr('src');
		@image_name = "#{get_orig_name}_#{get_year}_#{Time.now.usec}.png".tr(" ", "_")
		File.open("#{IMAGE_SAVE_PATH}#{image_name}", 'wb') do |f|
			f.write open(src).read
		end
		"#{IMAGE_DB_PATH}#{image_name}"
	end
end