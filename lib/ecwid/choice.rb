# frozen_string_literal: true

module Ecwid
  # Ecwid::Choice
  class Choice
    VALID_TYPES = %w[ABSOLUTE PERCENT].freeze

    attr_accessor :text, :value
    attr_reader :type

    def initialize(text = '', value = 0, type = 'ABSOLUTE')
      self.type = type

      @text  = text
      @value = value
    end

    def type=(type)
      raise TypeError unless VALID_TYPES.include?(type)

      @type = type
    end

    def to_h
      {
        text: text,
        priceModifier: value,
        priceModifierType: type
      }
    end
  end
end
