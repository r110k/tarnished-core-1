require 'rails_helper'

RSpec.describe "Items", type: :request do
  describe "获取账目" do

    xit "创建账目" do
      expect {
        post '/api/v1/items', params: { amount: 777 }
      }.to change { Item.count }.by +1
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['resource']['id']).to be_an(Numeric)
      expect(json['resource']['amount']).to eq 777
    end

    it "测试不登陆调用分页接口会401" do
      11.times { Item.create amount: rand(200000) }
      expect(Item.count).to eq 11
      get '/api/v1/items'
      expect(response).to have_http_status :unauthorized
    end

    it "分页" do
      user1 = User.create email: 'qin@civilization.vi'
      user2 = User.create email: 'judy@civilization.vi'
      expect(User.count).to eq 2

      11.times { Item.create amount: rand(200000), user_id: user1.id }
      21.times { Item.create amount: rand(400000), user_id: user2.id }
      expect(Item.count).to eq 32

      get '/api/v1/items', headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['resources'].size).to eq 10

      get '/api/v1/items?page=2', headers: user1.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['resources'].size).to eq 1
    end

    it "按时间筛选" do
      user = User.create email: 'judy@civilization.vi'
      item1 = Item.create amount: 200000, created_at: '1991-1-2', user_id: user.id
      item2 = Item.create amount: 200000, created_at: '1991-1-2', user_id: user.id
      item3 = Item.create amount: 10000, created_at: '1992-1-1', user_id: user.id

      get '/api/v1/items?created_after=1991-01-01&created_before=1991-1-3', headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['resources'].size).to eq 2
      expect(json['resources'][0]['id']).to eq item1.id
      expect(json['resources'][1]['id']).to eq item2.id
    end

    it "按时间筛选(边界条件)" do
      user = User.create email: 'judy@civilization.vi'
      # 这里(Time.new)默认使用了 +8 时区，会导致标准时区时间仍然在 1990-12-31 日，所以测试不通过
      # item1 = Item.create amount: 200000, created_at: Time.new(1991, 1, 1) 
      # 解决方案1, 指定标准时区（"+00:00" <=> "Z")
      # item1 = Item.create amount: 200000, created_at: Time.new(1991, 1, 1, 0, 0, 0, "Z") 
      # 解决方案2, 统一使用一个时区，使用字符串
      item1 = Item.create amount: 200000, created_at: '1991-01-01', user_id: user.id

      get '/api/v1/items?created_after=1991-01-01&created_before=1991-1-2', headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['resources'].size).to eq 1
      expect(json['resources'][0]['id']).to eq item1.id
    end

    it "按时间筛选测试只传开始时间" do
      user = User.create email: 'judy@civilization.vi'
      item1 = Item.create amount: 200000, created_at: '1991-01-01', user_id: user.id
      item2 = Item.create amount: 200000, created_at: '1990-01-01', user_id: user.id

      get '/api/v1/items?created_after=1991-01-01', headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['resources'].size).to eq 1
      expect(json['resources'][0]['id']).to eq item1.id
    end

    it "按时间筛选测试只传结束时间" do
      user = User.create email: 'judy@civilization.vi'
      item1 = Item.create amount: 200000, created_at: '1991-01-01', user_id: user.id
      item2 = Item.create amount: 200000, created_at: '1991-01-02', user_id: user.id

      get '/api/v1/items?created_before=1991-01-01', headers: user.generate_auth_header
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['resources'].size).to eq 1
      expect(json['resources'][0]['id']).to eq item1.id
    end

  end
end
