require 'rails_helper'


RSpec.describe "Mes", type: :request do
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
  end
end
