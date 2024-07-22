require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "账目" do
  get '/api/v1/items' do
    authentication :basic, :auth
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
    let(:current_user) { User.create email: 'judy@civilization.vi' }
    let(:auth) { "Bearer #{current_user.generate_jwt}" }
    example "获取账目" do
      11.times do Item.create amount: rand(20000), created_at: '2020-1-1', user_id: current_user.id end
      expect(Item.count).to eq 11

      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json['resources'].size).to eq 10
      expect(json['pager']['total']).to eq 11
    end

  end
end