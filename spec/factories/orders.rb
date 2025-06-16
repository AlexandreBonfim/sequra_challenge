FactoryBot.define do
  factory :order do
    id { Faker::Alphanumeric.unique.alphanumeric(number: 12).upcase }
    amount         { BigDecimal("100.00") }
    ordered_at     { Date.current }

    association :merchant
    merchant_reference { merchant.reference }
    disbursement { nil }
  end
end
