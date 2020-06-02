# frozen_string_literal: true

require 'coupon'

FactoryBot.define do
  factory :ecwid_coupon, class: Ecwid::Coupon do
    # :percent | :amount
    type  { :percent }
    value { 10 }
  end
end
