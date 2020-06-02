# frozen_string_literal: true

FactoryBot.define do
  factory :ecwid_coupon, class: Ecwid::Coupon do
    # :percent | :amount
    type  { :percent }
    value { 10 }
  end
end
