class Api::V1::TagsController < ApplicationController
  def index
    current_user = User.find request.env['current_user_id']
    return render status: :unauthorized if current_user.nil?
    tags = Tag.where({ user_id: current_user.id }).page params[:page]
    render json: { resources: tags, pager: { page: params[:page] || 1, per_page: Tag.default_per_page, total: Tag.count } }
  end

  def create
    current_user = User.find request.env['current_user_id']
    return render status: :unauthorized if current_user.nil?
    # 用下面的写法，感觉 create 的异常被吞掉了，返回的 tag 也没有 id
    # tag = Tag.create name: params[:name], sign: params[:sign], user_id: current_user.id
    # render json: { resource: tag }
    tag = Tag.new name: params[:name], sign: params[:sign], user_id: current_user.id
    if tag.save
      render json: { resource: tag }
    else
      render json: { errors: tag.errors }, status: :unprocessable_entity
    end
  end

  def update
    current_user = User.find request.env['current_user_id']
    return render status: :unauthorized if current_user.nil?
    tag = Tag.find params[:id]
    # 从 params 中取非空的值
    tag.update params.permit(:name, :sign)
    if tag.errors.empty?
      render json: { resource: tag }
    else
      render json: { errors: tag.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    current_user = User.find request.env['current_user_id']
    return render status: :unauthorized if current_user.nil?
    tag = Tag.find params[:id]
    return head :not_found if tag.nil?
    return head :forbidden unless tag.user_id === current_user.id
    tag.deleted_at = Time.now
    if (tag.save)
      head :ok
    else
      render json: { errors: tag.errors }, status: :unprocessable_entity
    end
  end

  def show
    current_user = User.find request.env['current_user_id']
    return render status: :unauthorized if current_user.nil?
    tag = Tag.find params[:id]
    return head :not_found if tag.nil?
    return head :forbidden unless tag.user_id === current_user.id
    render json: { resource: tag }
  end
end
