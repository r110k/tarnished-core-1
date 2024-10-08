require 'rails_helper'

RSpec.describe "Tags", type: :request do
  describe "获取标签列表" do
    it "测试不登陆获取标签接口会401" do
      get '/api/v1/tags'
      expect(response).to have_http_status :unauthorized
    end

    it "登陆后分页获取标签" do
      user = create :user
      another_user = create :user
      create_list :tag, Tag.default_per_page + 1, user: user
      create_list :tag, Tag.default_per_page + 1, user: another_user

      get '/api/v1/tags', headers: user.generate_auth_header
      expect(response).to have_http_status :ok
      json = JSON.parse(response.body)
      expect(json['resources'].size).to eq Tag.default_per_page

      get '/api/v1/tags?page=2', headers: user.generate_auth_header
      expect(response).to have_http_status :ok
      json = JSON.parse(response.body)
      expect(json['resources'].size).to eq 1
    end

    it "登陆后根据 kind 分页获取标签" do
      user = create :user
      create_list :tag, Tag.default_per_page + 1, kind: :income, user: user
      create_list :tag, Tag.default_per_page + 1, kind: :expenses, user: user

      get '/api/v1/tags', params: { kind: :income }, headers: user.generate_auth_header
      expect(response).to have_http_status :ok
      json = JSON.parse(response.body)
      expect(json['resources'].size).to eq Tag.default_per_page

      get '/api/v1/tags?page=2', params: { kind: :income }, headers: user.generate_auth_header
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
      user = create :user
      post '/api/v1/tags', params: {name: "tag_1", sign: "sign_1", user_id: user.id, kind: 'income'} ,headers: user.generate_auth_header
      expect(response).to have_http_status :ok
      json = JSON.parse(response.body)
      expect(json['resource']['name']).to eq 'tag_1'
      expect(json['resource']['sign']).to eq 'sign_1'
      expect(json['resource']['kind']).to eq 'income'
    end

    it "登陆后创建标签失败,因为没有填写name" do
      user = create :user
      post '/api/v1/tags', params: {sign: "sign_1", user_id: user.id} ,headers: user.generate_auth_header
      expect(response).to have_http_status :unprocessable_entity
      json = JSON.parse(response.body)
      expect(json['errors']['name'][0]).to eq "不能为空"
    end

    it "登陆后创建标签失败,因为没有填写sign" do
      user = create :user
      post '/api/v1/tags', params: {name: "tag_1", user_id: user.id} ,headers: user.generate_auth_header
      expect(response).to have_http_status :unprocessable_entity
      json = JSON.parse(response.body)
      expect(json['errors']['sign'][0]).to eq "不能为空"
    end
  end

  describe "修改标签" do
    it "测试不登陆修改标签接口会401" do
      tag = create :tag
      patch "/api/v1/tags/#{tag.id}", params: { id: tag.id, name: "tag_so", sign: "sign_soso", user_id: tag.user.id}
      expect(response).to have_http_status :unauthorized
    end

    it "登陆后修改标签" do
      tag = create :tag
      patch "/api/v1/tags/#{tag.id}", params: { id: tag.id, name: "tag_so", sign: "sign_soso", user_id: 'yyy'}, headers: tag.user.generate_auth_header
      expect(response).to have_http_status :ok
      json = JSON.parse(response.body)
      expect(json['resource']['name']).to eq 'tag_so'
      expect(json['resource']['sign']).to eq 'sign_soso'
      expect(json['resource']['user_id']).to eq tag.user.id
    end

    it "登陆后部分修改标签" do
      tag = create :tag
      patch "/api/v1/tags/#{tag.id}", params: { name: "tag_so" }, headers: tag.user.generate_auth_header
      expect(response).to have_http_status :ok
      json = JSON.parse(response.body)
      expect(json['resource']['name']).to eq 'tag_so'
      expect(json['resource']['sign']).to eq tag.sign
      expect(json['resource']['user_id']).to eq tag.user.id
    end
  end

  describe "删除标签" do
    it "测试不登陆删除标签接口会401" do
      tag = create :tag
      delete "/api/v1/tags/#{tag.id}"
      expect(response).to have_http_status :unauthorized
    end

    it "登陆后删除标签" do
      tag = create :tag
      delete "/api/v1/tags/#{tag.id}", headers: tag.user.generate_auth_header
      expect(response).to have_http_status :ok
      # tag.reload 等价于重新查一遍数据库 tag = Tag.find tag.id
      tag.reload
      expect(tag.deleted_at).not_to eq nil
    end

    it "登陆后删除别人的标签" do
      user = create :user
      tag = create :tag
      delete "/api/v1/tags/#{tag.id}", headers: user.generate_auth_header
      expect(response).to have_http_status :forbidden
      tag.reload
      expect(tag.deleted_at).to eq nil
    end

    it "删除标签和对应的记账" do
      user = create :user
      tag = create :tag, user: user
      items = create_list :item, 2, user: user, tag_ids: [tag.id]
      delete "/api/v1/tags/#{tag.id}", headers: user.generate_auth_header
      expect(response).to have_http_status(200)
      tag.reload
      items.first.reload
      items.second.reload
      expect(tag.deleted_at).not_to eq nil
      expect(items.first.deleted_at).not_to eq nil
      expect(items.second.deleted_at).not_to eq nil
    end
  end

  describe "获取单个标签" do
    it "测试不登陆获取标签接口会401" do
      tag = create :tag
      get "/api/v1/tags/#{tag.id}"
      expect(response).to have_http_status :unauthorized
    end

    it "登陆后获取单个标签" do
      tag = create :tag
      get "/api/v1/tags/#{tag.id}", headers: tag.user.generate_auth_header
      expect(response).to have_http_status :ok
      json = JSON.parse(response.body)
      expect(json['resource']['name']).to eq tag.name
      expect(json['resource']['sign']).to eq tag.sign
      expect(json['resource']['user_id']).to eq tag.user.id
    end

    it "登陆后不能获取别人的单个标签" do
      user = create :user
      tag = create :tag

      get "/api/v1/tags/#{tag.id}", headers: user.generate_auth_header
      expect(response).to have_http_status :forbidden
    end
  end
end
