# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/string'
require 'rest-client'
require 'json'

module Ecwid
  # Ecwid::Order
  class Order
    attr_accessor :line_items, :shipping, :customer, :discounts,
                  :payment_method, :store_id, :token, :id,
                  :coupon, :automatic_discount

    def save!
      make_request
    end

    def items
      items_params = line_items.map(&:to_h)

      items_params = send("apply_#{coupon.type}_coupon", items_params) if coupon
      items_params = send("apply_#{automatic_discount.type}_automatic_discount", items_params) if automatic_discount

      items_params
    end

    def apply_percent_coupon(items_params)
      items_params.map do |item|
        subtotal = item[:price] * item[:quantity]
        discount = subtotal * coupon.value / 100.0

        item.to_h.merge(
          couponApplied: true,
          couponAmount: discount.round(2)
        )
      end
    end

    # TODO: Rounding and handling the remainder
    def apply_amount_coupon(items_params)
      combined_subtotal = items_params.reduce(0) { |sum, item| sum + item[:price] * item[:quantity] }

      items_params.map do |item|
        subtotal = item[:price] * item[:quantity]
        discount = subtotal * coupon.value / combined_subtotal.to_f

        item.to_h.merge(
          couponApplied: true,
          couponAmount: discount
        )
      end
    end

    def apply_amount_automatic_discount(items_params)
      combined_subtotal = items_params.reduce(0) { |sum, item| sum + item[:price] * item[:quantity] }

      items_params.map do |item|
        subtotal = item[:price] * item[:quantity]
        discount = subtotal * automatic_discount.value / combined_subtotal.to_f

        item.to_h.merge(discounts: [{ discountInfo: {}, total: discount }])
      end
    end

    def apply_percent_automatic_discount(items_params)
      items_params.map do |item|
        subtotal = item[:price] * item[:quantity]
        discount = subtotal * automatic_discount.value / 100.0

        item.to_h.merge(
          discounts: [
            {
              discountInfo: {},
              total: discount
            }
          ]
        )
      end
    end

    def coupon_discount
      items.map { |item| item[:couponAmount] || 0 }.sum
    end

    def automatic_discount_amount
      if automatic_discount&.type == :amount
        automatic_discount.value
      elsif automatic_discount&.type == :percent
        items.map { |i| i[:discounts].map { |d| d[:total] } }.flatten.sum
      else
        0
      end
    end

    def discount_total
      # plus some other things
      coupon_discount + automatic_discount_amount
    end

    def params
      {
        subtotal: line_items.map(&:subtotal).sum,
        total: (line_items.map(&:total).sum + shipping.rate - discount_total).round(2),
        email: customer.email,
        paymentMethod: payment_method,
        tax: line_items.map(&:tax_total).sum.round(2),
        customerTaxExempt: false,
        customerTaxId: '',
        customerTaxIdValid: false,
        reversedTaxApplied: false,
        volumeDiscount: automatic_discount_amount,
        # discount: automatic_discount_amount,
        predictedPackage: [],
        taxesOnShipping: [],
        items: items,
        # I don't think this matters
        shippingPerson: shipping.pick_up ? customer.partial : customer.full,
        shippingOption: shipping.to_h,
        couponDiscount: coupon_discount
      }
    end

    def delete_products
      line_items.map(&:product).each(&:delete!)
    end

    private

    def make_request
      response = RestClient::Request.execute method: :post,
                                             url: "https://app.ecwid.com/api/v3/#{store_id}/orders",
                                             payload: params.to_json,
                                             headers: {
                                               # Params within headers form the query string
                                               params: { token: token },
                                               content_type: :json,
                                               accept: :json
                                             }

      @id = JSON.parse(response.body).fetch('id')
    end
  end
end
