# frozen_string_literal: true

module Ecwid
  # Ecwid::Shipping
  class Shipping
    attr_accessor :name, :rate, :pick_up, :instructions

    def to_h
      {
        shippingMethodName: name,
        shippingRate: rate,
        isPickup: pick_up
      }
    end
  end
end
