# frozen_string_literal: true

FactoryBot.define do
  factory :ecwid_choice, class: Ecwid::Choice do
    sequence(:text) { |n| "Choice #{n}" }
    value           { 0 }
    type            { 'ABSOLUTE' }

    initialize_with { new(text, value, type) }
  end
end
