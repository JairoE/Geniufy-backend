class Api::V1::UsersController < ApplicationController

  SPOTIFY = "https://api.spotify.com/v1"

  def login
    query_params = {
      client_id: ENV["CLIENT_ID"],
      response_type: "code",
      redirect_uri: ENV["REDIRECT_URI"],
      scope: "user-library-read user-library-modify user-top-read user-modify-playback-state playlist-modify-public playlist-modify-private user-read-currently-playing user-read-playback-state user-modify-playback-state streaming user-read-birthdate user-read-email user-read-private",
      show_dialog: true
    }

    url = "https://accounts.spotify.com/authorize"
    redirect_to "#{url}?#{query_params.to_query}"
  end

  def postLogin
    if params[:error]
      puts "LOGIN ERROR", params
      redirect_to "http://localhost:3001/home"
    else
      body={
        grant_type: "authorization_code",
        code: params[:code],
        redirect_uri: ENV['REDIRECT_URI'],
        client_id: ENV['CLIENT_ID'],
        client_secret: ENV['CLIENT_SECRET']
      }
      auth_response = RestClient.post('https://accounts.spotify.com/api/token', body)
      auth_params = JSON.parse(auth_response.body)
      header={
        Authorization: "Bearer #{auth_params["access_token"]}"
      }
      user_response = RestClient.get("https://api.spotify.com/v1/me", header)
      user_params = JSON.parse(user_response.body)

      username = user_params["display_name"]

      if user_params["display_name"] == nil
        username = user_params["id"]
      end

      @user = User.find_or_create_by(username: username,
                  spotify_url: user_params["external_urls"]["spotify"],
                  href: user_params["href"],
                  uri: user_params["uri"])



      payload = { user_id: @user.id }
      token = JWT.encode(payload, ENV['MY_SECRET'], ENV["OTHER"])

      @user.update(access_token: auth_params["access_token"], refresh_token: auth_params["refresh_token"])
      serialized_user = UserSerializer.new(@user).attributes

      render json: {user: serialized_user, code: token, auth: auth_params["access_token"]}
    end

  end

  def create

  end

  def show

  end

  def getPlaylists
    decodedId = JWT.decode(params[:jwt], ENV['MY_SECRET'], ENV["OTHER"])
    @user = User.find(decodedId[0]["user_id"])
    header = {Authorization: "Bearer #{@user.access_token}"}
    playlists = JSON.parse(RestClient.get((@user.href+"/playlists"), header))
    render json: playlists["items"]
  end

  def getPlaylistTracks
    decodedId = JWT.decode(params[:jwt], ENV['MY_SECRET'], ENV["OTHER"])
    @user = User.find(decodedId[0]["user_id"])
    header = {Authorization: "Bearer #{@user.access_token}"}
    byebug
    devices = JSON.parse(RestClient.get((SPOTIFY+"/me/player/devices"), header))["devices"]


  end

  def playTrack

  end

end
