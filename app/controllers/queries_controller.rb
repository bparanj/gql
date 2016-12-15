class QueriesController < ApplicationController
  protect_from_forgery with: :null_session
    
  def create
    query_string = params[:query]
    query_variables = params[:variables] || {}
    result = BlogSchema.execute(query_string, variables: query_variables)
    render json: result
  end
end
