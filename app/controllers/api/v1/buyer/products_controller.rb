class Api::V1::Buyer::ProductsController < ApplicationController
  before_action :authenticate_user!

  def browse
    authorize :product, :browse?
    render json: { authorized: true }
  end
end
