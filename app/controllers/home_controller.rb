class HomeController < ApplicationController
  def index
    render json: {
      msg: "Welcome, tarnished."
    }
  end
end
