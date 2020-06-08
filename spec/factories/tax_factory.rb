# frozen_string_literal: true

FactoryBot.define do
  factory :ecwid_tax, class: Ecwid::Tax do
    name  { "Tax #{SecureRandom.hex(2)}" }
    # Percentage value between 1% - 20%
    value { rand(100..2000) / 100.0 }
  end
end
