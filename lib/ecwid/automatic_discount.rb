# frozen_string_literal: true

module Ecwid
  # Ecwid::AutomaticDiscount
  class AutomaticDiscount
    attr_reader :type
    attr_accessor :value

    DISCOUNT_TYPES = %i[percent amount].freeze

    def type=(discount_type)
      raise TypeError unless DISCOUNT_TYPES.include?(discount_type)

      @type = discount_type
    end
  end
end
