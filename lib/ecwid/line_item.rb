# frozen_string_literal: true

module Ecwid
  # Ecwid::LineItem
  class Ecwid::LineItem
    attr_writer :coupon_amount, :discounts

    attr_reader :product,
                # :selected_options,
                :selections,
                :taxes,
                :quantity,
                :id,
                :product_id,
                :category_id,
                # :price,
                :product_price,
                :sku,
                :short_description,
                :short_description_translated,
                :tax,
                :shipping,
                :quantity_in_stock,
                :name,
                :name_translated,
                :is_shipping_required,
                :weight,
                :track_quantity,
                :fixed_shipping_rate_only,
                :fixed_shipping_rate,
                :digital,
                :product_available,
                # :coupon_applied,
                :dimensions,
                :discounts_allowed,
                :taxable,
                :is_gift_card

    def initialize(product:, quantity: 1, selections: [], taxes: [])
      @product    = product
      @quantity   = quantity
      @selections = selections
      @taxes      = taxes
    end

    def subtotal
      price * quantity
    end

    def total
      taxable_total + tax_total
    end

    def taxable_total
      subtotal - coupon_amount - discount_amount
    end

    def tax_total
      # (taxes || []).map { |t| (taxable_total * t.decimal_rate).round(2) }.sum
      tax_params.reduce(0) { |sum, tax| sum + tax[:total] }.round(2)
    end

    def tax_params
      taxes.map { |tax| tax.calculate_for(taxable_total) }
    end

    def add_options(price)
      return price unless selections&.any?

      result = price

      selected_options.map { |s| s[:selections] }.flatten.each do |choice|
        type  = choice[:selectionModifierType]
        value = choice[:selectionModifier]

        result += type == 'ABSOLUTE' ? value : price * value / 100.0
      end
      result
    end

    def price
      add_options(
        product.price_for_each(quantity)
      )
    end

    def selected_options
      return unless selections&.any?

      selections&.map do |selection|
        option  = product.options.find { |opt| opt.name == selection[:name] }
        choices = option.choices.select do |choice|
          choice.text == selection[:value] || selection.fetch(:values, []).include?(choice.text)
        end
        {
          name: option.name,
          value: choices.map(&:text).join(', '),
          valuesArray: option.type == 'CHECKBOX' ? selection[:values] : nil,
          type: option.type,
          selections: choices.map(&:as_selection)
        }.reject { |_k, v| v.nil? }
      end
    end

    def coupon_applied
      coupon_amount.positive?
    end

    def coupon_amount
      @coupon_amount || 0
    end

    def discount_amount
      discounts.map { |d| d[:total] }.sum
    end

    def discounts
      @discounts || []
    end

    def to_h
      {
        productId: product.id,
        name: product.name,
        price: price,
        productPrice: product.price,
        sku: product.sku,
        discountsAllowed: product.discounts_allowed,
        isGiftCard: product.is_gift_card,
        taxable: product.tax.fetch(:taxable),
        quantity: quantity,
        tax: tax_total,
        taxes: tax_params,
        selectedOptions: selected_options,
        couponApplied: coupon_applied,
        couponAmount: coupon_amount,
        discounts: discounts
      }.reject { |_k, v| v.nil? }
    end
  end
end

# "selectedOptions": [
    #     {
    #         "name": "Drop Down List",
    #         "nameTranslated": {
    #             "en": "Drop Down List"
    #         },
    #         "value": "Option Value 2",
    #         "valueTranslated": {
    #             "en": "Option Value 2"
    #         },
    #         "valuesArray": [
    #             "Option Value 2"
    #         ],
    #         "selections": [
    #             {
    #                 "selectionTitle": "Option Value 2",
    #                 "selectionModifier": 13,
    #                 "selectionModifierType": "PERCENT"
    #             }
    #         ],
    #         "type": "CHOICE"
    #     },
    #     {
    #         "name": "Checkboxes",
    #         "nameTranslated": {
    #             "en": "Checkboxes"
    #         },
    #         "value": "Option Value 1, Option Value 2",
    #         "valuesArray": [
    #             "Option Value 1",
    #             "Option Value 2"
    #         ],
    #         "selections": [
    #             {
    #                 "selectionTitle": "Option Value 1",
    #                 "selectionModifier": -5.5,
    #                 "selectionModifierType": "PERCENT"
    #             },
    #             {
    #                 "selectionTitle": "Option Value 2",
    #                 "selectionModifier": 2.1,
    #                 "selectionModifierType": "ABSOLUTE"
    #             }
    #         ],
    #         "type": "CHOICES"
    #     }
    # ],

    # "taxes": [
    #     {
    #         "name": "Tax",
    #         "value": 8.75,
    #         "total": 1.87,
    #         "taxOnDiscountedSubtotal": 1.87,
    #         "taxOnShipping": 0,
    #         "includeInPrice: false
    #     }
    # ],
