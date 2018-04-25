class Api::V1::SongsController < ApplicationController
  # BASEURL = "http://api.musixmatch.com/ws/1.1/"
  # MusixMatch::API::Base.api_key = '218055b0b637ebc699c5193c688beeac'
  include ActionView::Helpers::TextHelper

  GENIUS_API = "http://api.genius.com"
  GENIUS_URL = "https://genius.com"
  HEADERS = {'Authorization': 'Bearer qPqcniBSqCRmAfSWud8z2x6L_eQrMynoE1wlRNtNN6w5ATq2T4WKjjKkksZjMXWh'}

  def create
    # JSON.parse(RestClient.get(url))
    # response = MusixMatch.search_track(:q_artist => 'The Weeknd')
    # response = MusixMatch.search_track(:q_track => 'Call Out My Name')
    # if response.status_code == 200
    #   response.each do |track|
    #     puts "#{track.track_id}: #{track.track_name} (#{track.artist_name})"
    #   end
    # end
    #
    # track_id = 147914969
    # responsetwo = MusixMatch.get_lyrics(track_id)
    # if responsetwo.status_code == 200 && lyrics = responsetwo.lyrics
    #   puts lyrics.lyrics_body
    # end
    song_title = params[:song]
    artist_name = params[:artist]
    url = GENIUS_API + "/search?q=" + song_title.gsub(" ", "%20")
    json = JSON.parse(RestClient.get(url, headers=HEADERS))
    song_info = nil
    json["response"]["hits"].each do |hit|
      nameWithoutAccents = ActiveSupport::Inflector.transliterate(hit["result"]["primary_artist"]["name"])
      if nameWithoutAccents == artist_name && song_info == nil
        song_info = hit
      end
    end

    lyrics = nil
    if song_info != nil
      lyrics = lyrics_from_song_api(song_info["result"]["api_path"])
    end
    byebug
    render json: lyrics
  end

  def lyrics_from_song_api(path)
    song_url = GENIUS_API + path
    json = JSON.parse(RestClient.get(song_url, headers=HEADERS))
    song_path = json["response"]["song"]["path"]
    song_page_url = GENIUS_URL + song_path
    html = open(song_page_url)
    doc = Nokogiri::HTML(html)
    lyrics = doc.css(".lyrics").text
  end

  private

  def song_params
    params.require(:song).permit(:name, :artist)
  end

end
