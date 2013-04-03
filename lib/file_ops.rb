class FileOps

	attr_reader :image

	IMAGE_SAVE_PATH = "app/assets/images/posters/"
	IMAGE_DB_PATH	= "posters/"

	def get_image_from_url(url)
			name = url
			name.gsub(/[^a-zA-Z0-9]/, '').empty? ? regexp = src.gsub(/[^a-zA-Z0-9]/, '') : regexp = name.gsub(/[^a-zA-Z0-9]/, '')
			image_name = "#{regexp}_#{Time.now.usec}.png".tr(" ", "_")
			File.open("#{IMAGE_SAVE_PATH}#{image_name}", 'wb') do |f|
				f.write open(url).read
			end
			"#{IMAGE_DB_PATH}#{image_name}"
	end
end