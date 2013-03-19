class CreateGenres < ActiveRecord::Migration
  def change
    create_table :genres do |t|
      t.string :eng
      t.string :rus

      t.timestamps
    end
  end
end
