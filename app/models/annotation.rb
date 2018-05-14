class Annotation < ApplicationRecord
  belongs_to :user
  belongs_to :song
  has_many :annotation_threads
end
