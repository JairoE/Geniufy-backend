class Api::V1::PlaylistsController < ApplicationController

  SPOTIFY = "https://api.spotify.com/v1"

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
    # devices = JSON.parse(RestClient.get((SPOTIFY+"/me/player/devices"), header))["devices"]
    tracks = JSON.parse(RestClient.get(params[:playlistHREF], header))
    playlistTracks = []
    totalTracks = tracks["tracks"]["total"]

    tracks["tracks"]["items"].each do |track|
      if !track["is_local"]
        playlistTracks << {name: track["track"]["name"], artist: track["track"]["artists"][0]["name"], image: track["track"]["album"]["images"].last["url"], uri: track["track"]["uri"]}
      end

    end

    totalTracks=totalTracks-100

    while totalTracks > 0
      nexturl = tracks["tracks"]
      if nexturl == nil
        nexturl = tracks["next"]
      else
        nexturl = nexturl["next"]
      end
      tracks = JSON.parse(RestClient.get(nexturl, header))
      # byebug
      tracks["items"].each do |track|
        if !track["is_local"] && track["track"]["name"] != "" && track["track"]["album"]["images"].last != nil
          playlistTracks << {name: track["track"]["name"], artist: track["track"]["artists"][0]["name"], image: track["track"]["album"]["images"].last["url"], uri: track["track"]["uri"]}
        end

      end
      totalTracks = totalTracks - 100
    end

    playlistTracks = playlistTracks.reverse

    render json: playlistTracks

  end

  def playTrack
    decodedId = JWT.decode(params[:jwt], ENV['MY_SECRET'], ENV["OTHER"])
    @user = User.find(decodedId[0]["user_id"])
    header = {Authorization: "Bearer #{@user.access_token}"}
    devices = JSON.parse(RestClient.get((SPOTIFY+"/me/player/devices"), header))["devices"]
    device = devices.select do |device|
      device["name"] == "Music Player"
    end
    @user.update(current_device_id: device[0]["id"])
    payload = {uris: [params["trackId"]]}
    playTrack = JSON.parse(RestClient.put(SPOTIFY+"/me/player/play?device_id=#{device[0]["id"]}", payload.to_json, header))
    render json: {success: "true"}
  end

  def play
    decodedId = JWT.decode(params[:jwt], ENV['MY_SECRET'], ENV["OTHER"])
    @user = User.find(decodedId[0]["user_id"])
    header = {Authorization: "Bearer #{@user.access_token}"}
    RestClient.put(SPOTIFY+"/me/player/play?device_id=#{@user.current_device_id}",nil, header)
    render json: {success: "true"}
  end

  def pause
    decodedId = JWT.decode(params[:jwt], ENV['MY_SECRET'], ENV["OTHER"])
    @user = User.find(decodedId[0]["user_id"])
    puts @user.current_device_id
    header = {Authorization: "Bearer #{@user.access_token}"}
    RestClient.put(SPOTIFY+"/me/player/pause?device_id=#{@user.current_device_id}",nil, header)
    render json: {success: "true"}
  end

  def previous
    decodedId = JWT.decode(params[:jwt], ENV['MY_SECRET'], ENV["OTHER"])
    @user = User.find(decodedId[0]["user_id"])
    header = {Authorization: "Bearer #{@user.access_token}"}
  end

  def next
    decodedId = JWT.decode(params[:jwt], ENV['MY_SECRET'], ENV["OTHER"])
    @user = User.find(decodedId[0]["user_id"])
    header = {Authorization: "Bearer #{@user.access_token}"}
  end
end
