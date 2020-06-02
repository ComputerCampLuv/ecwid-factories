# frozen_string_literal: true

module Ecwid
  # Ecwid::Customer
  class Customer
    attr_accessor :email, :first_name, :last_name, :street, :city,
                  :country_code, :country_name, :postal_code,
                  :province_code, :province_name

    def name
      "#{first_name} #{last_name}"
    end

    def partial
      {
        name: name,
        firstName: first_name,
        lastName: last_name
      }
    end

    def full
      partial.merge(
        street: street,
        city: city,
        countryCode: country_code,
        countryName: country_name,
        postalCode: postal_code,
        stateOrProvinceCode: province_code,
        stateOrProvinceName: province_name
      )
    end
  end
end
