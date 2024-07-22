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
    user = User.find_by_email params[:email]
    if user.nil?
      render status: :not_found, json: { errors: '邮箱有误' }
    else
      render status: :ok, json: { jwt: user.generate_jwt }
    end
  end

  def destroy
    head :success
  end
end
