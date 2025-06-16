FactoryBot.define do
  factory :disbursement do
    reference { Faker::Alphanumeric.unique.alphanumeric(number: 10).upcase }
    date { Date.current }
    total_amount { 0 }
    total_fees { 0 }
    merchant
  end
end
