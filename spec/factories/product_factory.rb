# frozen_string_literal: true

FactoryBot.define do
  factory :ecwid_product, class: Ecwid::Product do
    name      { "Ecwid Item - #{SecureRandom.hex(2)}" }
    store_id  { ENV.fetch('ECWID_STORE_ID') }
    token     { ENV.fetch('ECWID_TOKEN') }
    unlimited { true }
    price     { rand(100..5000) / 100.0 }
  end
end
# wholesalePrices: [{"quantity": 2,"price": 9},{"quantity": 5,"price": 8}]
