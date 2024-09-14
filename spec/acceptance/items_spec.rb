require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "账目" do
  authentication :basic, :auth
  let(:current_user) { create :user }
  let(:auth) { "Bearer #{current_user.generate_jwt}" }
  let (:tags) { (0..3).map do |i| create :tag, user: current_user end }
  # &:id 等价于 当前的 id
  let (:tag_ids) { tags.map(&:id) }

  get '/api/v1/items' do
    parameter :page, '页码'
    parameter :happened_after, '发生时间起点'
    parameter :happened_before, '发生时间终点'

    # response_field :id, 'ID',scope: :resources
    # response_field :amount, '金额（单位：分）', scope: :resources
    # 上面两行等价于下面四行
    with_options :scope => :resources do 
      response_field :id, 'ID'
      response_field :amount, '金额（单位：分）'
    end
    let(:happened_after) { '2019-12-31' }
    let(:happened_before) { '2022-11-16' }
    example "获取账目" do
      items = create_list :item, Item.default_per_page + 1, happened_at: '2020-01-01', user: current_user, tag_ids: tag_ids
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json['resources'].size).to eq Item.default_per_page
      expect(json['pager']['total']).to eq Item.default_per_page + 1
    end

  end

  post '/api/v1/items' do
    parameter :amount, '金额（单位：分）', required: true
    parameter :kind, '类型', required: true
    parameter :tag_ids, '发生时间', required: true
    parameter :happened_at, '标签列表（只传id）', required: true

    with_options :scope => :resources do
      response_field :id, 'ID'
      response_field :amount, '金额（单位：分）'
      response_field :kind, '类型'
      response_field :happened_at, '发生时间'
      response_field :tag_ids, '标签列表（只传id）'
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
      tag = create :tag, user: current_user

      # 7-21: 10
      create :item, amount: 1000, kind: :income, happened_at: '2024-7-21T00:00:00+08:00', user: current_user, tag_ids: [tag.id]

      # 7-27 300
      create :item, amount: 4000, kind: :income, happened_at: '2024-7-27T00:00:00+08:00', user: current_user, tag_ids: [tag.id]
      create :item, amount: 5000, kind: :income, happened_at: '2024-7-27T00:00:00+08:00', user: current_user, tag_ids: [tag.id]
      create :item, amount: 6000, kind: :income, happened_at: '2024-7-27T00:00:00+08:00', user: current_user, tag_ids: [tag.id]
      create :item, amount: 7000, kind: :income, happened_at: '2024-7-27T00:00:00+08:00', user: current_user, tag_ids: [tag.id]
      create :item, amount: 8000, kind: :income, happened_at: '2024-7-27T00:00:00+08:00', user: current_user, tag_ids: [tag.id]

      # 7-23 50
      create :item, amount: 2000, kind: :income, happened_at: '2024-7-23T00:00:00+08:00', user: current_user, tag_ids: [tag.id]
      create :item, amount: 1500, kind: :income, happened_at: '2024-7-23T00:00:00+08:00', user: current_user, tag_ids: [tag.id]
      create :item, amount: 1500, kind: :income, happened_at: '2024-7-23T00:00:00+08:00', user: current_user, tag_ids: [tag.id]

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

      tag1 = create :tag, user: user
      tag2 = create :tag, user: user
      tag3 = create :tag, user: user

      # tag1: 50
      create :item, amount: 1000, kind: :income, happened_at: '2024-7-21T00:00:00+08:00', user: current_user, tag_ids: [tag1.id, tag2.id]
      # tag2: 60
      create :item, amount: 4000, kind: :income, happened_at: '2024-7-21T00:00:00+08:00', user: current_user, tag_ids: [tag1.id, tag3.id]
      # tag3: 90
      create :item, amount: 5000, kind: :income, happened_at: '2024-7-21T00:00:00+08:00', user: current_user, tag_ids: [tag2.id, tag3.id]

      do_request group_by: 'tag_id'
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json['groups'].size).to eq 3
      expect(json['total']).to eq 10000
      expect(json['groups'][0]['tag_id']).to eq tag3.id
      expect(json['groups'][0]['amount']).to eq 9000
      expect(json['groups'][0]['tag']['name']).to eq tag3.name
      expect(json['groups'][1]['tag_id']).to eq tag2.id
      expect(json['groups'][1]['amount']).to eq 6000
      expect(json['groups'][2]['tag_id']).to eq tag1.id
      expect(json['groups'][2]['amount']).to eq 5000
    end
  end

  get '/api/v1/items/balance' do
    parameter :happeneded_after, '时间起点', required: true
    parameter :happeneded_before, '时间终点', required: true

    response_field :income, '收入'
    response_field :expenses, '支出'
    response_field :balance, '余额'

    let(:happeneded_after) { '2024-6-29' }
    let(:happeneded_before) { '2024-7-22' }
    example "获取支出、收入、余额" do
      user = current_user
      # income 3550000 expenses 1000000
      create :item, amount: 3500000, kind: :income, happened_at: '2024-7-1T00:00:00+08:00', user: user
      create :item, amount: 56250, kind: :expenses, happened_at: '2024-7-2T00:00:00+08:00', user: user
      create :item, amount: 56250, kind: :expenses, happened_at: '2024-7-3T00:00:00+08:00', user: user
      create :item, amount: 56250, kind: :expenses, happened_at: '2024-7-4T00:00:00+08:00', user: user
      create :item, amount: 56250, kind: :expenses, happened_at: '2024-7-5T00:00:00+08:00', user: user
      create :item, amount: 56250, kind: :expenses, happened_at: '2024-7-6T00:00:00+08:00', user: user
      create :item, amount: 56250, kind: :expenses, happened_at: '2024-7-7T00:00:00+08:00', user: user
      create :item, amount: 56250, kind: :expenses, happened_at: '2024-7-8T00:00:00+08:00', user: user
      create :item, amount: 56250, kind: :expenses, happened_at: '2024-7-9T00:00:00+08:00', user: user
      create :item, amount: 56250, kind: :expenses, happened_at: '2024-7-10T00:00:00+08:00', user: user
      create :item, amount: 56250, kind: :expenses, happened_at: '2024-7-11T00:00:00+08:00', user: user
      create :item, amount: 56250, kind: :expenses, happened_at: '2024-7-12T00:00:00+08:00', user: user
      create :item, amount: 56250, kind: :expenses, happened_at: '2024-7-13T00:00:00+08:00', user: user
      create :item, amount: 56250, kind: :expenses, happened_at: '2024-7-14T00:00:00+08:00', user: user
      create :item, amount: 56250, kind: :expenses, happened_at: '2024-7-15T00:00:00+08:00', user: user
      create :item, amount: 56250, kind: :expenses, happened_at: '2024-7-16T00:00:00+08:00', user: user
      create :item, amount: 56250, kind: :expenses, happened_at: '2024-7-17T00:00:00+08:00', user: user
      create :item, amount: 100000, kind: :expenses, happened_at: '2024-7-19T00:00:00+08:00', user: user
      create :item, amount: 50000, kind: :income, happened_at: '2024-7-20T00:00:00+08:00', user: user
      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json['income']).to eq 3550000
      expect(json['expenses']).to eq 1000000
      expect(json['balance']).to eq 2550000
    end

  end
end