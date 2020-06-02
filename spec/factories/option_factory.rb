# frozen_string_literal: true

require 'option'

FactoryBot.define do
  factory :ecwid_option, class: Ecwid::Option do
    sequence(:name) { |n| "Option #{n}" }
    default_choice  { 1 }
    required        { false }
    choices         { build_list :ecwid_choice, 3 }

    trait :drop_down do
      type { 'SELECT' }
    end

    trait :radio do
      type { 'RADIO' }
    end

    trait :size do
      name { 'Size' }
      type { 'SIZE' }
    end

    trait :checkbox do
      type           { 'CHECKBOX' }
      required       { false }
      default_choice { nil }
    end

    trait :text_field do
      type           { 'TEXTFIELD' }
      choices        { nil }
      default_choice { nil }
    end

    trait :text_area do
      type           { 'TEXTAREA' }
      choices        { nil }
      default_choice { nil }
    end

    trait :date do
      type           { 'DATE' }
      choices        { nil }
      default_choice { nil }
    end

    trait :files do
      type           { 'FILES' }
      choices        { nil }
      default_choice { nil }
    end

    trait :no_default do
      default_choice  { nil }
      required        { true }
    end
  end
end
