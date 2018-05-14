class Api::V1::AnnotationsController < ApplicationController
  def create
    decodedUserId = JWT.decode(params[:jwt], ENV['MY_SECRET'], ENV["OTHER"])
    @annotation = Annotation.create(song_id: params[:song_id], user_id: decodedUserId[0]["user_id"], annotation: params[:annotationText])

    render json: @annotation
  end

  def show
    @annotation = Annotation.find(params[:id])
    @username = User.find(@annotation.user_id).username
    annotations = AnnotationThread.where(annotation_id: @annotation.id)
    if annotations.size != 0
      annotations = annotations.map do |annotation|
        anno = Annotation.find(annotation.chained_annotation_Id)
        user = User.find(anno.user_id)
        {annotation: anno, username: user.username}
      end
      annotations.unshift({annotation: @annotation, username: @username})
      render json: annotations.to_json
    else
      render json: [{annotation: @annotation, username: @username}].to_json
    end
  end

  def chainAnnotation
    decodedUserId = JWT.decode(params[:jwt], ENV['MY_SECRET'], ENV["OTHER"])
    @chainedAnnotation = Annotation.create(song_id: params[:song_id], user_id: decodedUserId[0]["user_id"], annotation: params[:annotationText])
    AnnotationThread.create(annotation_id: params[:annotation_id], chained_annotation_Id: @chainedAnnotation.id)
    render json: {success: "true"}
  end

end
