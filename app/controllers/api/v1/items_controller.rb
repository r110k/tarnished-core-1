class Api::V1::ItemsController < ApplicationController
  def create
    current_user = User.find request.env['current_user_id']
    return render status: :unauthorized if current_user.nil?

    item = Item.new params.permit(:amount, :happened_at, :kind, tags_id: [])
    item.user_id = current_user.id
    if item.save
      render json: { resource: item }
    else
      render json: { errors: item.errors }, status: :unprocessable_entity
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

  def summary 
    hash = Hash.new
    current_user_id = request.env['current_user_id']
    return head :unauthorized if current_user_id.nil?

    items = Item.where(user_id: current_user_id)
      .where(kind: params[:kind])
      .where(happened_at: params[:happened_after]..params[:happened_before])
    items.each do |item|
      if params[:group_by] == 'happened_at'
        key = item.happened_at.in_time_zone('Beijing').strftime('%F')
        hash[key] ||= 0
        hash[key] += item.amount
      else
        item.tags_id.each do |tag_id|
          hash[tag_id] ||= 0
          hash[tag_id] += item.amount
        end
      end
    end
    # groups = hash.map { |key, value| { :happened_at: key, amount: value } }
    # # <=> spaceship sign 用 A - B -1 升序 （感叹号是原地自升，不生成新的）
    # groups.sort! { |a, b| a[:happened_at] <=> b[:happened_at] }
    # 上面三行可以使用链式调用改写为
    groups = hash.map { |key, value| { "#{params[:group_by]}": key, amount: value } }
    if params[:group_by] == 'happened_at'
      groups.sort! { |a, b| a[:happened_at] <=> b[:happened_at] }
    elsif params[:group_by] == 'tag_id'
      groups.sort! { |a, b| b[:amount] <=> a[:amount] }
    end
    render json: {
      groups: groups,
      total: items.sum(:amount)
    }
  end
end
