# frozen_string_literal: true

module Ecwid
  # Ecwid::Tax
  class Tax
    attr_accessor :name, :value

    def decimal_rate
      value / 100.0
    end

    def calculate_for(product, quantity)
      {
        name: name,
        value: value,
        total: (quantity * product.price * decimal_rate).round(2),
        taxOnDiscountedSubtotal: (quantity * product.price * decimal_rate).round(2),
        taxOnShipping: 0,
        includeInPrice: false
      }
    end
  end
end
