class OrderService
  def self.call(dto)
    new(dto).call
  end

  def initialize(dto)
    @dto = dto
  end

  def call
    return ServiceResult.failure([ "merchant not found" ]) unless merchant

    create_order

    if @order&.persisted?
      ServiceResult.success(@order)
    else
      ServiceResult.failure(@order.errors.full_messages)
    end
  rescue => e
    ServiceResult.failure([ e.message ])
  end

  private

  attr_reader :dto

  def create_order
    @order = Order.create(
      dto.attributes.merge(merchant_reference: merchant.reference)
    )
  end

  def merchant
    @merchant ||= Merchant.find_by(id: dto.merchant_id)
  end
end
