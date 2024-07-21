class Api::V1::ValidationCodesController < ApplicationController

  def create
    # if ValidationCode.exists?(email: params[:email], kind: 'sign_in', created_at: 1.minute.ago..Time.now)
    #   # https://http.cat/429
    #   render status :too_many_requests
    #   return
    # end

    # Ruby if 后置语法糖
    return render status: :too_many_requests if ValidationCode.exists?(email: params[:email], kind: 'sign_in', created_at: 1.minute.ago..Time.now)

    validation_code = ValidationCode.new email: params[:email], kind: 'sign_in'
    if validation_code.save
      render status: 200
    else
      render json: { errors: validation_code.errors }, status: 422
    end
  end

end
