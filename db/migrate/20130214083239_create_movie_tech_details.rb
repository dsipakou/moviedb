class CreateMovieTechDetails < ActiveRecord::Migration
  def change
    create_table :movie_tech_details do |t|
      t.string :movie_id
      t.string :duration
      t.string :filesize
      t.string :resolution
      t.string :filetype
      t.string :screenshots

      t.timestamps
    end
  end
end
