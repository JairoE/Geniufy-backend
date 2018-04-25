class SongSerializer < ActiveModel::Serializer
  attributes :id, :name, :artist, :lyrics
end
