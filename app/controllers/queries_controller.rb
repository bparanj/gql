class QueriesController < ApplicationController
  protect_from_forgery with: :null_session
    
  def create
    query_string = params[:query]
    result = BlogSchema.execute(query_string)
    render json: result
  end
end
