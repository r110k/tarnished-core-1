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

  describe "修改标签" do
    it "测试不登陆修改标签接口会401" do
      user = User.create email: 'judy@civilization.vi'
      tag = Tag.create  name: "tag_2", sign: "sign_1", user_id: user.id 
      patch "/api/v1/tags/#{tag.id}", params: { id: tag.id, name: "tag_so", sign: "sign_soso", user_id: user.id}
      expect(response).to have_http_status :unauthorized
    end

    it "登陆后修改标签" do
      user = User.create email: 'judy@civilization.vi'
      tag = Tag.create name: "tag_2", sign: "sign_1", user_id: user.id
      patch "/api/v1/tags/#{tag.id}", params: { id: tag.id, name: "tag_so", sign: "sign_soso", user_id: 'yyy'}, headers: user.generate_auth_header
      expect(response).to have_http_status :ok
      json = JSON.parse(response.body)
      expect(json['resource']['name']).to eq 'tag_so'
      expect(json['resource']['sign']).to eq 'sign_soso'
      expect(json['resource']['user_id']).to eq user.id
    end

    it "登陆后部分修改标签" do
      user = User.create email: 'judy@civilization.vi'
      tag = Tag.create name: "tag_2", sign: "sign_1", user_id: user.id
      patch "/api/v1/tags/#{tag.id}", params: { name: "tag_so" }, headers: user.generate_auth_header
      expect(response).to have_http_status :ok
      json = JSON.parse(response.body)
      expect(json['resource']['name']).to eq 'tag_so'
      expect(json['resource']['sign']).to eq 'sign_1'
      expect(json['resource']['user_id']).to eq user.id
    end
  end

  describe "删除标签" do
    it "测试不登陆删除标签接口会401" do
      user = User.create email: 'judy@civilization.vi'
      tag = Tag.create  name: "tag_2", sign: "sign_1", user_id: user.id 
      delete "/api/v1/tags/#{tag.id}"
      expect(response).to have_http_status :unauthorized
    end

    it "登陆后删除标签" do
      user = User.create email: 'judy@civilization.vi'
      tag = Tag.create name: "tag_2", sign: "sign_1", user_id: user.id
      delete "/api/v1/tags/#{tag.id}", headers: user.generate_auth_header
      expect(response).to have_http_status :ok
      # tag.reload 等价于重新查一遍数据库 tag = Tag.find tag.id
      tag.reload
      expect(tag.deleted_at).not_to eq nil
    end

    it "登陆后删除别人的标签" do
      user = User.create email: 'judy@civilization.vi'
      another_user = User.create email: 'tian@civilization.vi'
      tag = Tag.create name: "tag_2", sign: "sign_1", user_id: another_user.id
      delete "/api/v1/tags/#{tag.id}", headers: user.generate_auth_header
      expect(response).to have_http_status :forbidden
      # tag.reload 等价于重新查一遍数据库 tag = Tag.find tag.id
      tag.reload
      expect(tag.deleted_at).to eq nil
    end
  end
end
