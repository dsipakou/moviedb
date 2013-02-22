class CreateMovies < ActiveRecord::Migration
  def change
    create_table :movies do |t|
      t.string :disknum
      t.string :name
      t.string :orig_name
      t.string :year
      t.string :genre
      t.string :director
      t.string :produced
      t.string :stars
      t.string :actors
      t.string :composer
      t.string :lang
      t.string :imdb
      t.string :remarks
      t.string :desc
      t.string :imdb_link
      t.string :image_link
      t.string :imdbhtml1
      t.string :imdbhtml2

      t.timestamps
    end
  end
end
