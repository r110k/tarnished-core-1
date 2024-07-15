class Api::V1::ItemsController < ApplicationController
  def create
    amount = rand(1000001)
    p amount
    item = Item.new amount: amount
    if item.save
      render json: { resource: item }
    else
      render json: { errors: item.errors }
    end
  end

  def index
    items = Item.page params[:page]
    render json: { 
      resource: items,
      pager: {
        page: params[:page],
        per_page: 200,
	      total: Item.count
      }
    }
  end
end
