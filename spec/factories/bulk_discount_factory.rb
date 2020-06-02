# frozen_string_literal: true

require 'bulk_discount'

FactoryBot.define do
  factory :ecwid_bulk_discount, class: Ecwid::BulkDiscount do
    quantity { 2 }
    price    { 8 }

    initialize_with { new(quantity, price) }
  end
end
