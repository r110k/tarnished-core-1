class Api::V1::ItemsController < ApplicationController
  def create
    current_user = User.find request.env['current_user_id']
    return render status: :unauthorized if current_user.nil?

    item = Item.new params.permit(:amount, :tags_id, :happen_at)
    item.user_id = current_user.id
    if item.save
      render json: { resource: item }
    else
      render json: { errors: item.errors }
    end
  end

  def index
    current_user_id = request.env['current_user_id']
    return head :unauthorized if current_user_id.nil?
    items = Item.where({ user_id: current_user_id })
        .where({created_at: params[:created_after]..params[:created_before]})
        .page params[:page]
    render json: { 
      resources: items,
      pager: {
        page: params[:page] || 1,
        per_page: Item.default_per_page,
	      total: Item.count
      }
    }
  end
end
