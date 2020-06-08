# frozen_string_literal: true

FactoryBot.define do
  factory :ecwid_line_item, class: Ecwid::LineItem do
    product    { build :ecwid_product }
    quantity   { 1 }
    selections { [] }
    taxes      { [] }

    initialize_with do
      new product: product,
          quantity: quantity,
          selections: selections,
          taxes: taxes
    end
  end
end
