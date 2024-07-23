require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "账目" do
  authentication :basic, :auth
  let(:current_user) { User.create email: 'judy@civilization.vi' }
  let(:auth) { "Bearer #{current_user.generate_jwt}" }
  let (:tags) { (0..3).map do |i| Tag.create name: "tag#{i}", sign: "sign#{i}", user_id: current_user.id end }
  # &:id 等价于 当前的 id
  let (:tags_id) { tags.map(&:id) }

  get '/api/v1/items' do
    parameter :page, '页码'
    parameter :created_after, '创建时间起点'
    parameter :created_before, '创建时间终点'

    # response_field :id, 'ID',scope: :resources
    # response_field :amount, '金额（单位：分）', scope: :resources
    # 上面两行等价于下面四行
    with_options :scope => :resources do 
      response_field :id, 'ID'
      response_field :amount, '金额（单位：分）'
    end
    let(:created_after) { '2019-12-31' }
    let(:created_before) { '2022-11-16' }
    example "获取账目" do
      # create! 感叹号会让 create 抛出错误，否则默认会吞掉报错
      11.times do 
        Item.create! amount: rand(20000), created_at: '2020-1-1', user_id: current_user.id,
          kind: :income, happened_at: '2024-8-23T00:00:00+08:00', tags_id: tags_id
      end

      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json['resources'].size).to eq 10
      expect(json['pager']['total']).to eq 11
    end

  end

   post '/api/v1/items' do
    parameter :amount, '金额（单位：分）', required: true
    parameter :kind, '类型', required: true
    parameter :tags_id, '发生时间', required: true
    parameter :happened_at, '标签列表（只传id）', required: true

    with_options :scope => :resources do
      response_field :id, 'ID'
      response_field :amount, '金额（单位：分）'
      response_field :kind, '类型'
      response_field :happened_at, '发生时间'
      response_field :tags_id, '标签列表（只传id）'
      response_field :user_id, '用户 ID'
      response_field :deleted_at, '删除时间'
    end
   
    let (:amount) { 77700 }
    let (:kind) { 'income' }
    let (:happened_at) { '2024-8-23T00:00:00+08:00' }

    example "创建账目" do
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json['resource']['amount']).to eq amount
    end
  end
end