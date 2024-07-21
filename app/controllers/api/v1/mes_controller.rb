class Api::V1::MesController < ApplicationController
  def show
    user_id = request.env['current_user_id'] rescue ''
    user = User.find user_id
    return head :not_found if user.nil? 
    render json: { resource: user }
  end
end
