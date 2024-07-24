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

   get '/api/v1/items/summary' do
    parameter :happeneded_after, '时间起点', required: true
    parameter :happeneded_before, '时间终点', required: true
    parameter :kind, '账目类型', enum: ['expensive', 'income'], required: true
    parameter :group_by, '分组依据', enum: ['happened_at', 'tag_id'], required: true

    response_field :groups, '分组信息'
    response_field :total, '总金额（单位：分）'

    with_options :scope => :groups do
      response_field :amount, '金额（单位：分）'
      response_field :happened_at, '消费时间'
      response_field :tag_id, '标签 id'
    end

    let(:happeneded_after) { '2023-12-31' }
    let(:happeneded_before) { '2025-1-1' }
    let(:kind) { 'income' }
    example "统计信息(按 happened_at 分组)" do

      user = current_user
      tag = Tag.create name: "tag1", sign: "sign1", user_id: user.id

      # 7-21: 10
      Item.create! amount: 1000, kind: :income, happened_at: '2024-7-21T00:00:00+08:00',
          created_at: '2025-1-1', user_id: user.id, tags_id: [tag.id]

      # 7-27 300
      Item.create! amount: 4000, kind: :income, happened_at: '2024-7-27T00:00:00+08:00',
          created_at: '2025-1-1', user_id: user.id, tags_id: [tag.id]
      Item.create! amount: 5000, kind: :income, happened_at: '2024-7-27T00:00:00+08:00',
          created_at: '2025-1-1', user_id: user.id, tags_id: [tag.id]
      Item.create! amount: 6000, kind: :income, happened_at: '2024-7-27T00:00:00+08:00',
          created_at: '2025-1-1', user_id: user.id, tags_id: [tag.id]
      Item.create! amount: 7000, kind: :income, happened_at: '2024-7-27T00:00:00+08:00',
          created_at: '2025-1-1', user_id: user.id, tags_id: [tag.id]
      Item.create! amount: 8000, kind: :income, happened_at: '2024-7-27T00:00:00+08:00',
          created_at: '2025-1-1', user_id: user.id, tags_id: [tag.id]

      # 7-23 50
      Item.create! amount: 2000, kind: :income, happened_at: '2024-7-23T00:00:00+08:00',
          created_at: '2025-1-1', user_id: user.id, tags_id: [tag.id]
      Item.create! amount: 1500, kind: :income, happened_at: '2024-7-23T00:00:00+08:00',
          created_at: '2025-1-1', user_id: user.id, tags_id: [tag.id]
      Item.create! amount: 1500, kind: :income, happened_at: '2024-7-23T00:00:00+08:00',
          created_at: '2025-1-1', user_id: user.id, tags_id: [tag.id]

      do_request group_by: 'happened_at'
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json['groups'].size).to eq 3
      expect(json['groups'][0]['happened_at']).to eq '2024-07-21'
      expect(json['groups'][0]['amount']).to eq 1000
      expect(json['groups'][1]['happened_at']).to eq '2024-07-23'
      expect(json['groups'][1]['amount']).to eq 5000
      expect(json['groups'][2]['happened_at']).to eq '2024-07-27'
      expect(json['groups'][2]['amount']).to eq 30000
    end

    example "统计信息（按 tag_id 分组）" do

      user = current_user

      tag1 = Tag.create name: "tag1", sign: "sign1", user_id: user.id
      tag2 = Tag.create name: "tag1", sign: "sign1", user_id: user.id
      tag3 = Tag.create name: "tag1", sign: "sign1", user_id: user.id

      # tag1: 50
      Item.create! amount: 1000, kind: :income, happened_at: '2024-7-21T00:00:00+08:00',
          created_at: '2025-1-1', user_id: user.id, tags_id: [tag1.id, tag2.id]
      # tag2: 60
      Item.create! amount: 4000, kind: :income, happened_at: '2024-7-27T00:00:00+08:00',
          created_at: '2025-1-1', user_id: user.id, tags_id: [tag1.id, tag3.id]
      # tag3: 90
      Item.create! amount: 5000, kind: :income, happened_at: '2024-7-27T00:00:00+08:00',
          created_at: '2025-1-1', user_id: user.id, tags_id: [tag2.id, tag3.id]

      do_request group_by: 'tag_id'
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json['groups'].size).to eq 3
      expect(json['total']).to eq 10000
      expect(json['groups'][0]['tag_id']).to eq tag3.id
      expect(json['groups'][0]['amount']).to eq 9000
      expect(json['groups'][1]['tag_id']).to eq tag2.id
      expect(json['groups'][1]['amount']).to eq 6000
      expect(json['groups'][2]['tag_id']).to eq tag1.id
      expect(json['groups'][2]['amount']).to eq 5000
    end
  end
end