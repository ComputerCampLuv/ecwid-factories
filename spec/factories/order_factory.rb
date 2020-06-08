# frozen_string_literal: true

FactoryBot.define do
  factory :ecwid_order, class: Ecwid::Order do
    items              { build_list(:ecwid_line_item, 1) }
    shipping_option    { build :ecwid_shipping }
    shipping_person    { build :ecwid_customer }
    payment_method     { 'Pay by Cash' }
    store_id           { ENV.fetch('ECWID_STORE_ID') }
    token              { ENV.fetch('ECWID_TOKEN') }
    coupon             { nil }
    automatic_discount { nil }
    # discounts       { [] }

    initialize_with do
      new items: items,
          shipping_option: shipping_option,
          shipping_person: shipping_person,
          payment_method: payment_method,
          store_id: store_id,
          token: token,
          coupon: coupon,
          automatic_discount: automatic_discount
    end

    # trait :coupon_applied do
    #   coupon { build :ecwid_coupon }
    # end
  end
end
