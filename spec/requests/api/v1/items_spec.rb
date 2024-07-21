require 'rails_helper'

RSpec.describe "Items", type: :request do
  describe "Index by page" do
    it "Can get 200 items default by page" do
      201.times { Item.create amount: rand(20000) }
      expect(Item.count).to eq 201
      get '/api/v1/items'
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['resources'].size).to eq 100
      get '/api/v1/items?page=3'
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['resources'].size).to eq 1
    end
  end
  describe "Create item" do
    it "Can create a new item" do
      expect {
        post '/api/v1/items', params: { amount: 777 }
      }.to change { Item.count }.by +1
      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['resource']['id']).to be_an(Numeric)
      expect(json['resource']['amount']).to eq 777
    end
  end
end
