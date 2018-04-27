class Api::V1::AnnotationsController < ApplicationController
  def create
    @annotation = Annotation.create(song_id: params[:song_id], user_id: 1, annotation: params[:annotationText])

    render json: @annotation
  end

  def show
    @annotation = Annotation.find(params[:id])
    render json: @annotation
  end
end
