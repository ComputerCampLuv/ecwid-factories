# frozen_string_literal: true

module Ecwid
  # Ecwid::Tax
  class Tax
    attr_accessor :name, :value, :include_shipping, :include_in_price

    attr_writer :tax_on_discounted_subtotal, :tax_on_shipping

    def decimal_rate
      value / 100.0
    end

    def calculate_for(amount)
      amount *= decimal_rate
      {
        name: name,
        value: value,
        total: amount.round(2),
        taxOnDiscountedSubtotal: amount.round(2),
        taxOnShipping: 0,
        includeInPrice: false
      }
    end

    def to_h
      {
        name: name,
        value: value,
        total: total,
        taxOnDiscountedSubtotal: tax_on_discounted_subtotal,
        taxOnShipping: tax_on_shipping,
        includeInPrice: include_in_price || false
      }
    end

    def total
      (tax_on_discounted_subtotal + tax_on_shipping).round(2)
    end

    def tax_on_discounted_subtotal
      (@tax_on_discounted_subtotal ||= 0).round(2)
    end

    def tax_on_shipping
      (@tax_on_shipping ||= 0).round(2)
    end
  end
end
