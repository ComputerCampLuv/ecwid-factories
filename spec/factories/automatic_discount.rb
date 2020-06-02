# frozen_string_literal: true

require 'automatic_discount'

FactoryBot.define do
  factory :ecwid_auto_discount, class: Ecwid::AutomaticDiscount do
    # :percent | :amount
    type  { :amount }
    value { 2 }
  end
end
