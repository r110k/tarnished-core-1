require 'rails_helper'

RSpec.describe "Tags", type: :request do
  describe "获取标签" do
    it "测试不登陆获取标签接口会401" do
      get '/api/v1/tags'
      expect(response).to have_http_status :unauthorized
    end

    it "登陆后分页获取标签" do
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

  describe "创建标签" do
    it "测试不登陆创建标签接口会401" do
      post '/api/v1/tags'
      expect(response).to have_http_status :unauthorized
    end

    it "登陆后创建标签" do
      user = User.create email: 'judy@civilization.vi'
      post '/api/v1/tags', params: {name: "tag_1", sign: "sign_1", user_id: user.id} ,headers: user.generate_auth_header
      expect(response).to have_http_status :ok
      json = JSON.parse(response.body)
      expect(json['resource']['name']).to eq 'tag_1'
      expect(json['resource']['sign']).to eq 'sign_1'
    end

    it "登陆后创建标签失败,因为没有填写name" do
      user = User.create email: 'judy@civilization.vi'
      post '/api/v1/tags', params: {sign: "sign_1", user_id: user.id} ,headers: user.generate_auth_header
      expect(response).to have_http_status :unprocessable_entity
      json = JSON.parse(response.body)
      expect(json['errors']['name'][0]).to eq "can't be blank"
    end

    it "登陆后创建标签失败,因为没有填写sign" do
      user = User.create email: 'judy@civilization.vi'
      post '/api/v1/tags', params: {name: "tag_1", user_id: user.id} ,headers: user.generate_auth_header
      expect(response).to have_http_status :unprocessable_entity
      json = JSON.parse(response.body)
      expect(json['errors']['sign'][0]).to eq "can't be blank"
    end
  end
end
