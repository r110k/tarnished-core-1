class Api::V1::TagsController < ApplicationController
  def index
    current_user = User.find request.env['current_user_id']
    return render status: :unauthorized if current_user.nil?
    tags = Tag.where(user_id: current_user.id).page params[:page]
    tags = tags.where(kind: params[:kind]) unless params[:kind].nil?
    render json: { resources: tags, pager: { page: params[:page] || 1, per_page: Tag.default_per_page, total: Tag.count } }
  end

  def create
    current_user = User.find request.env['current_user_id']
    return render status: :unauthorized if current_user.nil?
    tag = Tag.new name: params[:name], sign: params[:sign], kind: params[:kind]
    tag.user = current_user
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
    current_user_id = request.env['current_user_id']
    tag = Tag.find params[:id]
    return head :not_found if tag.nil?
    return head :forbidden unless tag.user_id === current_user_id
    tag.deleted_at = Time.now
    ActiveRecord::Base.transaction do
      begin
        if params[:with_items] == 'true'
          Item.where('tag_ids && ARRAY[?]::bigint[]', [tag.id])
              .update!(deleted_at: Time.now)
        end
        tag.save!
      rescue => exception
        return render json: { errors: tag.errors }, status: :unprocessable_entity
      end
    end
    head :ok
  end

  def show
    current_user_id = request.env['current_user_id']
    tag = Tag.find params[:id]
    return head :not_found if tag.nil?
    return head :forbidden unless tag.user_id === current_user_id
    render json: { resource: tag }
  end
end
