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

  def show
  end
end
