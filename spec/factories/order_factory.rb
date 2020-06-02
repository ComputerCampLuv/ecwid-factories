# frozen_string_literal: true

FactoryBot.define do
  factory :ecwid_order, class: Ecwid::Order do
    line_items     { build_list(:ecwid_line_item, 1) }
    shipping       { build(:ecwid_shipping) }
    customer       { build(:ecwid_customer) }
    payment_method { 'Pay by Cash' }
    store_id       { ENV.fetch('ECWID_STORE_ID') }
    token          { ENV.fetch('ECWID_TOKEN') }
    coupon         { nil }
    discounts      { [] }

    trait :coupon_applied do
      coupon { build(:ecwid_coupon) }
    end
  end
end
