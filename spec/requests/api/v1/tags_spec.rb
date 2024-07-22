require 'rails_helper'

RSpec.describe "Tags", type: :request do
  describe "标签" do

    it "测试不登陆获取标签接口会401" do
      get '/api/v1/tags'
      expect(response).to have_http_status :unauthorized
    end

    it "获取标签" do
      user = User.create email: 'judy@civilization.vi'
      11.times do |i| Tag.create name: "tag#{i}", sign: "sign#{i}", user_id: user.id end
      another_user = User.create email: 'tian@civilization.vi'
      11.times do |i| Tag.create name: "tag#{i}", sign: "sign#{i}", user_id: another_user.id end

      get '/api/v1/tags', headers: user.generate_auth_header
      expect(response).to have_http_status :ok
      json = JSON.parse(response.body)
      expect(json['resources'].size).to eq 10

      get '/api/v1/tags?page=2', headers: user.generate_auth_header
      expect(response).to have_http_status :ok
      json = JSON.parse(response.body)
      expect(json['resources'].size).to eq 1
    end
  end
end
