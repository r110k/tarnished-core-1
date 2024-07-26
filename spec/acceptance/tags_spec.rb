require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "标签" do
  authentication :basic, :auth
  let(:current_user) { create :user }
  let(:auth) { "Bearer #{current_user.generate_jwt}" }

  get '/api/v1/tags' do
    parameter :page, '页码'
    parameter :kind, '类型', in: [ 'income', 'expenses']

    with_options :scope => :resources do
      response_field :id, 'ID'
      response_field :name, '名称'
      response_field :sign, '符号'
      response_field :user_id, '用户 ID'
      response_field :deleted_at, '删除时间'
    end
   
    example "分页获取标签列表" do
      11.times do |i| Tag.create name: "tag#{i}", sign: "sign#{i}", user_id: current_user.id end
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json['resources'].size).to eq 10
    end

  end

  post '/api/v1/tags' do
    parameter :name, '名称', required: true
    parameter :sign, '符号', required: true

    with_options :scope => :resources do
      response_field :id, 'ID'
      response_field :name, '名称'
      response_field :sign, '符号'
      response_field :user_id, '用户 ID'
      response_field :deleted_at, '删除时间'
    end
   
    let (:name) { 'tag_1' }
    let (:sign) { 'sign_1' }
    example "创建标签" do
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json['resource']['name']).to eq name
      expect(json['resource']['sign']).to eq sign
      expect(json['resource']['user_id']).to eq current_user.id
    end
  end

  patch '/api/v1/tags/:id' do
    let(:tag) { Tag.create name: 'tag_1', sign: 'sign_1', user_id: current_user.id }
    let(:id) { tag.id }

    parameter :name, '名称'
    parameter :sign, '符号'

    with_options :scope => :resources do
      response_field :id, 'ID'
      response_field :name, '名称'
      response_field :sign, '符号'
      response_field :user_id, '用户 ID'
      response_field :deleted_at, '删除时间'
    end
   
    let (:name) { 'tag_so' }
    let (:sign) { 'sign_so' }

    example "更新标签" do
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json['resource']['name']).to eq name
      expect(json['resource']['sign']).to eq sign
    end

  end

  delete '/api/v1/tags/:id' do
    let(:tag) { Tag.create name: 'tag_1', sign: 'sign_1', user_id: current_user.id }
    let(:id) { tag.id }

    example "删除标签" do
      do_request
      expect(status).to eq 200
    end
  end

  get '/api/v1/tags/:id' do
    let(:tag) { Tag.create name: 'tag_1', sign: 'sign_1', user_id: current_user.id }
    let(:id) { tag.id }

    with_options :scope => :resources do
      response_field :id, 'ID'
      response_field :name, '名称'
      response_field :sign, '符号'
      response_field :user_id, '用户 ID'
      response_field :deleted_at, '删除时间'
    end

    example "获取单个标签" do
      do_request
      expect(status).to eq 200

      json = JSON.parse response_body
      expect(json['resource']['name']).to eq tag.name
      expect(json['resource']['sign']).to eq tag.sign
      expect(json['resource']['user_id']).to eq current_user.id
    end
  end
end