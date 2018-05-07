class Api::V1::SongsController < ApplicationController

  GENIUS_API = "http://api.genius.com"
  GENIUS_URL = "https://genius.com"
  HEADERS = {'Authorization': 'Bearer '+ GENIUSK}

  def create

    song = Song.find_by(genius_api_path: params[:api_link])
    if song != nil
      render json: song and return
    end

    song = lyrics_from_song_api(params[:api_link])

    render json: song
  end

  def lyrics_from_song_api(path)
    song_url = GENIUS_API + path
    json = JSON.parse(RestClient.get(song_url, headers=HEADERS))
    song_path = json["response"]["song"]["path"]
    song_page_url = GENIUS_URL + song_path
    html = open(song_page_url)
    doc = Nokogiri::HTML(html)
    lyrics = doc.css(".lyrics").text.gsub("\n", "<br />")
    Song.create(name: json["response"]["song"]["title"],
                artist: json["response"]["song"]["primary_artist"]["name"],
                lyrics: lyrics,
                genius_api_path: path)
  end

  def fetchSongs
    song = params[:input]
    url = GENIUS_API + "/search?q=" + song.gsub(" ", "%20")
    json = JSON.parse(RestClient.get(url, headers=HEADERS))

    songs = json["response"]["hits"].map do |hit|
            {full_song: hit["result"]["full_title"], api_path: hit["result"]["api_path"], song_image: hit["result"]["header_image_thumbnail_url"]}
          end

    render json: songs
  end

  def playSong
    song = params[:song]
    song = song.gsub(8217.chr, "'")
    if song.index("-") != nil
      song = song[0...song.index("-")]
    end

    if song.index("(") != nil
      song = song[0...song.index("(")]
    end

    url = GENIUS_API + "/search?q=" + song.gsub(" ", "%20")

    json = JSON.parse(RestClient.get(url, headers=HEADERS))
    
    songapi = json["response"]["hits"].select do |hit|
      hit["result"]["primary_artist"]["name"].include?(params[:artist])
    end[0]["result"]["api_path"]

    song = Song.find_by(genius_api_path: songapi)
    if song != nil
      render json: song and return
    end

    song = lyrics_from_song_api(songapi)

    render json: song
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
