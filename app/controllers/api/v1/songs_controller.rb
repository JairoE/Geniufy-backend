class Api::V1::SongsController < ApplicationController

  GENIUS_API = "http://api.genius.com"
  GENIUS_URL = "https://genius.com"
  HEADERS = {'Authorization': 'Bearer '+ GENIUSK}

  def create
    song_title = params[:song].downcase.capitalize.strip
    artist_name = params[:artist].downcase.capitalize.strip
    song = Song.find_by(name: song_title, artist: artist_name)
    if song != nil
      render json: song and return
    else
      song = Song.create(name: song_title, artist: artist_name)
    end

    url = GENIUS_API + "/search?q=" + song_title.gsub(" ", "%20")
    json = JSON.parse(RestClient.get(url, headers=HEADERS))
    song_info = nil
    json["response"]["hits"].each do |hit|
      nameWithoutAccents = ActiveSupport::Inflector.transliterate(hit["result"]["primary_artist"]["name"])
      # casecmp outputs 0 if the two strings are the same regardless of capitalization
      if nameWithoutAccents.casecmp(artist_name)==0 && song_info == nil
        song_info = hit
      end
    end
    lyrics = nil
    if song_info != nil
      lyrics = lyrics_from_song_api(song_info["result"]["api_path"])
    end

    song.update(lyrics: (lyrics).gsub("\n", "<br />"))

    render json: song
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


  def update
    song = Song.find(params[:id])
    song.update(lyrics: params[:lyrics])

    render json: song
  end
  private

  def song_params
    params.require(:song).permit(:name, :artist)
  end
end
