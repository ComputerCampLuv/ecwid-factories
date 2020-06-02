# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :ecwid_customer, class: Ecwid::Customer do
    email         { Faker::Internet.email }
    first_name    { Faker::Name.first_name }
    last_name     { Faker::Name.last_name }
    street        { Faker::Address.street_address }
    city          { Faker::Address.city }
    postal_code   { Faker::Address.zip_code }
    # country_code  { }
    country_name  { Faker::Address.country }
    # province_code { }
    province_name { Faker::Address.state }
  end
end
