class Api::V1::OrdersController < ApplicationController
  def create
    dto = OrderCreateDto.new(order_params)

    return render json: { errors: dto.errors.full_messages }, status: :unprocessable_entity unless dto.valid?

    result = OrderService.call(dto)

    if result.success?
      render json: OrderPresenter.new(result.payload).as_json, status: :created
    else
      render json: { errors: result.errors }, status: :unprocessable_entity
    end
  end

  private

  def order_params
    params.require(:order).permit(:amount, :ordered_at, :merchant_id)
  end
end
