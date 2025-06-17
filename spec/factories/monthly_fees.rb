FactoryBot.define do
  factory :monthly_fee do
    merchant
    year { 2024 }
    month { 5 }
    amount { 10.0 }
  end
end
