class Song < ApplicationRecord
  has_many :favorites
  has_many :annotations 
end
