# frozen_string_literal: true

require 'tax'

FactoryBot.define do
  factory :ecwid_tax, class: Ecwid::Tax do
    name  { 'VAT' }
    # Percentage value between 1% - 20%
    value { rand(100..2000) / 100.0 }
  end
end
