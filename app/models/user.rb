class User < ApplicationRecord
  has_many :follows
  has_many :annotations
  has_many :favorites
end
