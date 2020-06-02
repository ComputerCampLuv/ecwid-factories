# frozen_string_literal: true

module Ecwid
  # Ecwid::BulkDiscount
  class BulkDiscount
    attr_accessor :quantity, :price

    def initialize(quantity, price)
      @quantity = quantity
      @price    = price
    end

    def to_h
      {
        quantity: quantity,
        price: price
      }
    end
  end
end
