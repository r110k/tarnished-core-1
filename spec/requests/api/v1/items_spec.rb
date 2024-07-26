require 'rails_helper'

RSpec.describe "Items", type: :request do
  describe "创建账目" do
    it "未登录创建账目会报401" do
      post '/api/v1/items'
      expect(response).to have_http_status :unauthorized
    end

    it "可以创建账目" do
      user = create :user
      tag1 = create :tag, user: user
      tag2 = create :tag, user: user

      post '/api/v1/items', params: { amount: "888", tag_ids: [tag1.id, tag2.id], happened_at: '2024-7-23T00:00:00+08:00' } ,headers: user.generate_auth_header
      expect(response).to have_http_status :ok
      json = JSON.parse(response.body)
      expect(json['resource']['id']).to be_an Numeric
      expect(json['resource']['amount']).to eq 888
      expect(json['resource']['user_id']).to eq user.id
      expect(json['resource']['happened_at']).to eq '2024-07-22T16:00:00.000Z'
    end

    it "创建账目时 amount、tag_ids 必填" do
      user = create :user
      post '/api/v1/items', params: {} ,headers: user.generate_auth_header
      expect(response).to have_http_status :unprocessable_entity
      json = JSON.parse(response.body)
      expect(json['errors']['amount'][0]).to eq "不能为空"
      expect(json['errors']['tag_ids'][0]).to eq "不能为空"
      expect(json['errors']['happened_at'][0]).to eq "不能为空"
    end

  end

  describe "获取账目" do
    it "测试不登陆调用分页接口会401" do
      get '/api/v1/items'
      expect(response).to have_http_status :unauthorized
    end

    it "分页" do
      user1 = create :user
      user2 = create :user

      create_list :item, Item.default_per_page + 1, user: user1
      create_list :item, 21, user: user2

      get '/api/v1/items', headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['resources'].size).to eq Item.default_per_page

      get '/api/v1/items?page=2', headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['resources'].size).to eq 1
    end

    it "按时间筛选" do
      user = create :user
      item1 = create :item, created_at: '1991-1-1', user: user
      item2 = create :item, created_at: '1991-1-2', user: user
      item3 = create :item, created_at: '1992-1-1', user: user

      get '/api/v1/items?created_after=1991-01-01&created_before=1991-1-3', headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['resources'].size).to eq 2
      expect(json['resources'][0]['id']).to eq item1.id
      expect(json['resources'][1]['id']).to eq item2.id
    end

    it "按时间筛选(边界条件)" do
      # 这里(Time.new)默认使用了 +8 时区，会导致标准时区时间仍然在 1990-12-31 日，所以测试不通过
      # item1 = Item.create amount: 200000, created_at: Time.new(1991, 1, 1) 
      # 解决方案1, 指定标准时区（"+00:00" <=> "Z")
      # item1 = Item.create amount: 200000, created_at: Time.new(1991, 1, 1, 0, 0, 0, "Z") 
      # 解决方案2, 统一使用一个时区，使用字符串
      user = create :user
      item = create :item, created_at: '1991-1-1', user: user

      get '/api/v1/items?created_after=1991-01-01&created_before=1991-1-2', headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['resources'].size).to eq 1
      expect(json['resources'][0]['id']).to eq item.id
    end

    it "按时间筛选测试只传开始时间" do
      user = create :user
      item1 = create :item, created_at: '1991-1-1', user: user
      item2 = create :item, created_at: '1990-1-1', user: user

      get '/api/v1/items?created_after=1991-01-01', headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['resources'].size).to eq 1
      expect(json['resources'][0]['id']).to eq item1.id
    end

    it "按时间筛选测试只传结束时间" do
      user = create :user
      item1 = create :item, created_at: '1991-1-1', user: user
      item2 = create :item, created_at: '1991-1-2', user: user

      get '/api/v1/items?created_before=1991-01-01', headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['resources'].size).to eq 1
      expect(json['resources'][0]['id']).to eq item1.id
    end

  end

  describe "统计" do
    it "按天分组" do
      current_user = create :user
      tag = create :tag, user: current_user

      # 7-21: 10
      create :item, amount: 1000, kind: :income, happened_at: '2024-7-21T00:00:00+08:00', created_at: '2025-1-1', user: current_user, tag_ids: [tag.id]

      # 7-27 300
      create :item, amount: 4000, kind: :income, happened_at: '2024-7-27T00:00:00+08:00', created_at: '2025-1-1', user: current_user, tag_ids: [tag.id]
      create :item, amount: 5000, kind: :income, happened_at: '2024-7-27T00:00:00+08:00', created_at: '2025-1-1', user: current_user, tag_ids: [tag.id]
      create :item, amount: 6000, kind: :income, happened_at: '2024-7-27T00:00:00+08:00', created_at: '2025-1-1', user: current_user, tag_ids: [tag.id]
      create :item, amount: 7000, kind: :income, happened_at: '2024-7-27T00:00:00+08:00', created_at: '2025-1-1', user: current_user, tag_ids: [tag.id]
      create :item, amount: 8000, kind: :income, happened_at: '2024-7-27T00:00:00+08:00', created_at: '2025-1-1', user: current_user, tag_ids: [tag.id]

      # 7-23 50
      create :item, amount: 2000, kind: :income, happened_at: '2024-7-23T00:00:00+08:00', created_at: '2025-1-1', user: current_user, tag_ids: [tag.id]
      create :item, amount: 1500, kind: :income, happened_at: '2024-7-23T00:00:00+08:00', created_at: '2025-1-1', user: current_user, tag_ids: [tag.id]
      create :item, amount: 1500, kind: :income, happened_at: '2024-7-23T00:00:00+08:00', created_at: '2025-1-1', user: current_user, tag_ids: [tag.id]

      get '/api/v1/items/summary', params: {
        happened_after: '2023-12-31',
        happened_before: '2025-1-1',
        kind: :income,
        group_by: :happened_at,
      }, headers: current_user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['groups'].size).to eq 3
      expect(json['total']).to eq 36000
      expect(json['groups'][0]['happened_at']).to eq '2024-07-21'
      expect(json['groups'][0]['amount']).to eq 1000
      expect(json['groups'][1]['happened_at']).to eq '2024-07-23'
      expect(json['groups'][1]['amount']).to eq 5000
      expect(json['groups'][2]['happened_at']).to eq '2024-07-27'
      expect(json['groups'][2]['amount']).to eq 30000
    end

    it "按标签分组" do
      user = create :user
      current_user = user
      tag1 = create :tag, user: user
      tag2 = create :tag, user: user
      tag3 = create :tag, user: user
      # tag1: 50
      create :item, amount: 1000, kind: :income, happened_at: '2024-7-21T00:00:00+08:00', created_at: '2025-1-1', user: current_user, tag_ids: [tag1.id, tag2.id]
      # tag2: 60
      create :item, amount: 4000, kind: :income, happened_at: '2024-7-21T00:00:00+08:00', created_at: '2025-1-1', user: current_user, tag_ids: [tag1.id, tag3.id]
      # tag3: 90
      create :item, amount: 5000, kind: :income, happened_at: '2024-7-21T00:00:00+08:00', created_at: '2025-1-1', user: current_user, tag_ids: [tag2.id, tag3.id]
      get '/api/v1/items/summary', params: { happened_after: '2023-12-31', happened_before: '2025-1-1', kind: :income, group_by: :tag_id, }, headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
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
