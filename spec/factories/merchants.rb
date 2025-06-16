FactoryBot.define do
  factory :merchant do
    id          { SecureRandom.uuid }
    reference   { Faker::Company.unique.name.parameterize }
    email       { Faker::Internet.unique.email }
    live_on              { Date.current }
    disbursement_frequency { Merchant::DISBURSEMENT_FREQUENCIES.sample }
    minimum_monthly_fee  { 0.0 }
  end
end
