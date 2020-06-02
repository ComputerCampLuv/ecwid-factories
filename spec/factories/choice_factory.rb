# frozen_string_literal: true

FactoryBot.define do
  factory :ecwid_choice, class: Ecwid::Choice do
    sequence(:text) { |n| "Choice #{n}" }
    value           { 1 }
    type            { 'ABSOLUTE' }
  end
end
