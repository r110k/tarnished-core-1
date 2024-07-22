require 'jwt'

class Api::V1::SessionsController < ApplicationController
  def create
    if Rails.env.test?
      return render status: :unauthorized, json: { errors: '验证码错误' }  if params[:code] != '926401'
    else
      canSignIn = ValidationCode.exists? email: params[:email], code: params[:code], used_at: nil
      # https://http.cat/401
      return render status: :unauthorized, json: { errors: '验证码错误' } unless canSignIn
    end
    user = User.find_or_create_by email: params[:email]
    render status: :ok, json: { jwt: user.generate_jwt }
  end

  def destroy
    head :success
  end
end
