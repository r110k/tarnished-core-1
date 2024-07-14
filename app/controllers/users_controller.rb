class UsersController < ApplicationController
  def create
    p 'create'
    user = User.new name: 'huxueyan'
    # user = User.new email: 'huxueyan@wanqing.com', name: 'huxueyan'
    if user.save
      p '✨ 成功保存'
      render json: user
    else 
      p '💀 保存失败'
      render json: user.errors
    end
  end

  def show
    p 'show'
    user = User.find_by_id params[:id]
    if user
      render json: user
    else
      head 404
    end
  end
end
