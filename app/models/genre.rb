class Genre < ActiveRecord::Base
  attr_accessible :eng, :rus
  belongs_to :movie
end
