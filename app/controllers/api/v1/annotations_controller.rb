class Api::V1::AnnotationsController < ApplicationController
  def create
    decodedUserId = JWT.decode(params[:jwt], ENV['MY_SECRET'], ENV["OTHER"])
    @annotation = Annotation.create(song_id: params[:song_id], user_id: decodedUserId[0]["user_id"], annotation: params[:annotationText])

    render json: @annotation
  end

  def show
    @annotation = Annotation.find(params[:id])
    @username = User.find(@annotation.user_id).username
    render json: {annotation: @annotation, username: @username}
  end
end
