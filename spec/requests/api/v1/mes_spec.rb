require 'rails_helper'
require 'active_support/testing/time_helpers'

RSpec.describe "Mes", type: :request do
  include ActiveSupport::Testing::TimeHelpers
  describe "当前用户" do
    it "成功登录后能被获取" do
      # 登录
      user = User.create email: 'Springatom@hotmail.com'
      post '/api/v1/session', params: { email: 'Springatom@hotmail.com', code: '926401' }
      data = JSON.parse response.body
      jwt = data['jwt']

      # 获取
      get '/api/v1/me', headers: { 'Authorization': "Bearer #{jwt}" }
      expect(response).to have_http_status(:ok)
      data = JSON.parse response.body
      expect(data['resource']['id']).to eq user.id
    end

    it "jwt可以过期" do
      travel_to Time.now - 3.hours
      user = User.create email: 'judy@civilization.vi'
      jwt = user.generate_jwt

      travel_back
      get '/api/v1/me', headers: { 'Authorization': "Bearer #{jwt}" }
      expect(response).to have_http_status :unauthorized
    end

    it "jwt没过期" do
      travel_to Time.now - 1.hours
      user = User.create email: 'judy@civilization.vi'
      jwt = user.generate_jwt

      travel_back
      get '/api/v1/me', headers: { 'Authorization': "Bearer #{jwt}" }
      expect(response).to have_http_status :ok
    end
  end
end
