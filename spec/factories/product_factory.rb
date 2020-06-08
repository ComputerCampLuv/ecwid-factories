# frozen_string_literal: true

FactoryBot.define do
  factory :ecwid_product, class: Ecwid::Product do
    store_id       { ENV.fetch('ECWID_STORE_ID') }
    token          { ENV.fetch('ECWID_TOKEN') }
    name           { "Ecwid Item - #{SecureRandom.hex(2)}" }
    unlimited      { true }
    price          { rand(100..5000) / 100.0 }
    bulk_discounts { nil }
    options        { nil }
    id             { nil }

    initialize_with do
      new name: name,
          price: price,
          unlimited: unlimited,
          bulk_discounts: bulk_discounts,
          options: options,
          store_id: store_id,
          token: token,
          id: id
    end
  end
end
