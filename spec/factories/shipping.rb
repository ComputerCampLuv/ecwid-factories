# frozen_string_literal: true

require 'shipping'

FactoryBot.define do
  factory :ecwid_shipping, class: Ecwid::Shipping do
    name    { 'Shipping' }
    rate    { 5 }
    pick_up { false }

    trait :pick_up do
      name    { 'Pick Up' }
      rate    { 0 }
      pick_up { true }
    end
  end
end
