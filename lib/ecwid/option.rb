# frozen_string_literal: true

module Ecwid
  # Ecwid::Option
  class Option
    MODIFIER_TYPES = %w[
      SELECT
      RADIO
      SIZE
      CHECKBOX
    ].freeze

    VALID_TYPES = MODIFIER_TYPES + %w[
      TEXTFIELD
      TEXTAREA
      DATE
      FILES
    ].freeze

    attr_accessor :name, :choices, :default_choice, :required
    attr_reader :type

    def initialize(name = '', type = 'SELECT', choices = nil, default_choice = nil, required = false)
      self.type = type

      @name           = name
      @choices        = choices
      @default_choice = default_choice
      @required       = required
    end

    def type=(type)
      raise TypeError unless VALID_TYPES.include?(type)

      @type = type
    end

    def to_h
      {
        type: type,
        name: name,
        choices: choices&.map(&:to_h),
        defaultChoice: default_choice,
        required: required
      }.reject { |_k, v| v.nil? }
    end

    def default
      choices[default_choice]
    end
  end
end
