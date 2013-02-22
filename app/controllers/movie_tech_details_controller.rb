class MovieTechDetailsController < ApplicationController
  def new
    @tech_details = MovieTechDetail.new
  end
end
