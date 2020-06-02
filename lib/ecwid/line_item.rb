# frozen_string_literal: true

module Ecwid
  # Ecwid::LineItem
  class LineItem
    attr_accessor :product, :quantity, :discounts, :taxes

    def subtotal
      product.price * quantity
    end

    def total
      subtotal + tax_total
    end

    def tax_total
      tax_params.reduce(0) { |sum, tax| sum + tax[:total] }.round(2)
    end

    def tax_params
      taxes.map { |tax| tax.calculate_for(product, quantity) }
    end

    def to_h
      {
        productId: product.id,
        name: product.name,
        price: product.price,
        productPrice: product.price,
        categoryId: product.defaultCategoryId,
        sku: product.sku,
        discountsAllowed: product.discountsAllowed,
        isGiftCard: product.isGiftCard,
        taxable: product.tax.fetch(:taxable),
        quantity: quantity,
        tax: tax_total,
        taxes: tax_params,
        discounts: discounts
      }
    end
  end
end
