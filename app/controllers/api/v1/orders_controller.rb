class Api::V1::OrdersController < ApplicationController
  before_action :check_login, only: %i[index show create]
  before_action :set_order, only: %i[show]
  before_action :order_params, only: [:create]
  def index
    render json: OrderSerializer.new(current_user.orders).serializable_hash
  end

  def show
    if @order
      render json: OrderSerializer.new(@order, include: [:products])
    else
      head 404
    end
  end

  def create
    order = current_user.orders.build(order_params)
    if order.save
      OrderMailer.send_confirmation(order).deliver
      render json: order, status: 201
    else
      render json: {errors: order.errors}, status: 422
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:total, product_ids: [])
  end
end
