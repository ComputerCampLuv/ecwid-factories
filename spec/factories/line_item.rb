# frozen_string_literal: true

require 'line_item'

FactoryBot.define do
  factory :ecwid_line_item, class: Ecwid::LineItem do
    product         { create(:ecwid_product) }
    quantity        { 1 }
    taxes           { [] }
    discounts       { [] }

    trait :tax_applied do
      taxes { build_list(:ecwid_tax, 1) }
    end
  end
end
