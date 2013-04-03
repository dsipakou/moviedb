require 'nokogiri'
require 'open-uri'

class Kinopoisk

	RATING_XPATH = "//a[contains(text(), 'xml')]"

	def initialize(url)
		@url = url
		@rus_page = get_rus_page(@url)
	end

	private
	def get_rus_page(url)
		Nokogiri::HTML(open(url), nil, 'Windows-1251')
	end

	def get_items(page, xpath)
		items = Array.new
		page.xpath(xpath).each do |item|
			items << item
		end
		items.empty? ? nil : items.join(", ").squish
	end

	public
	def get_rating
		get_items(@rus_page, RATING_XPATH)
	end
end
