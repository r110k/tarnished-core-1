require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "账目" do
  get '/api/v1/items' do
    parameter :page, '页码'
    parameter :created_after, '创建时间起点'
    parameter :created_before, '创建时间终点'

    response_field :id, 'ID',scope: :resources
    response_field :amount, '金额（单位：分）', scope: :resources
    # 上面两行等价于下面四行
    with_options :scope => :resources do 
      response_field :id, 'ID'
      response_field :amount, '金额（单位：分）'
    end
    let(:created_after) { '2019-12-31' }
    let(:created_before) { '2022-11-16' }
    example "获取账目" do
      201.times do Item.create amount: rand(20000), created_at: '2020-1-1' end
      expect(Item.count).to eq 201

      do_request
      expect(status).to eq 200
      json = JSON.parse response_body
      expect(json['resources'].size).to eq 10
      expect(json['pager']['total']).to eq 201
    end

  end
end