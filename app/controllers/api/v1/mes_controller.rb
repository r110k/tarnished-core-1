class Api::V1::MesController < ApplicationController
  def show
    header = request.headers["Authorization"]
    # Bearer jwt
    jwt = header.split(' ')[1] rescue ''
    payload = JWT.decode jwt, Rails.application.credentials.hmac_secret, true, { algorithm: 'HS256' } rescue nil
    return head :not_found if payload.nil?
    # payload ex: [{"user_id"=>24}, {"alg"=>"HS256"}]
    user_id = payload[0]['user_id'] rescue nil
    user = User.find user_id
    return head :not_found if user.nil? 
    render json: { resource: user }
  end
end
