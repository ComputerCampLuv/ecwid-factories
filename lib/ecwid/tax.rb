# frozen_string_literal: true

module Ecwid
  # Ecwid::Tax
  class Tax
    attr_accessor :name, :value

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
  end
end
