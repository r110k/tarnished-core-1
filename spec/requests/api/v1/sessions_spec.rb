require 'rails_helper'


RSpec.describe "Sessions", type: :request do
  describe "会话" do
    it "能创建会话" do
      create :user
      post '/api/v1/session', params: { email: 'Springatom@hotmail.com', code: '000000' }
      expect(response).to have_http_status(200)
      data = JSON.parse response.body
      expect(data['jwt']).to be_a(String)
    end
    it "首次登陆" do
      post '/api/v1/session', params: { email: 'Springatom@hotmail.com', code: '000000' }
      expect(response).to have_http_status(200)
      data = JSON.parse response.body
      expect(data['jwt']).to be_a(String)
    end
  end
end
