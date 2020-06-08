# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/string'
require 'rest-client'
require 'json'

module Ecwid
  # Ecwid::Order
  class Order
    attr_accessor :items,
                  :billing_person,
                  :shipping_person,
                  :shipping_option,
                  :automatic_discount

    attr_reader :vendor_order_number,
                :refunded_amount,
                :gift_card_redemption,
                :total_before_gift_card_redemption,
                :payment_method,
                :customer_tax_exempt,
                :customer_tax_id,
                :customer_tax_id_valid,
                :reversed_tax_applied,
                :ip_address,
                :coupon,
                :payment_status,
                :fulfillment_status,
                :order_number,
                :referer_url,
                :order_comments,
                :customer_id,
                :membership_based_discount,
                :total_and_membership_based_discount,
                :usd_total,
                :global_referer,
                :create_date,
                :update_date,
                :create_timestamp,
                :update_timestamp,
                :refunds,
                :handling_fee,
                :predicted_package,
                :shipments,
                :additional_info,
                :payment_params,
                :hidden,
                :accept_marketing,
                :disable_all_customer_notifications,
                :external_fulfillment

    def initialize(data = {})
      data.each do |var, value|
        instance_variable_set("@#{var}", value)
      end
      # NOTE: Order is important. Coupon should be applied first
      apply_coupon if coupon
      apply_volume_discount if automatic_discount
      distribute_shipping
      apply_taxes
    end

    def update_variables(data = {})
      data.each do |var, value|
        var.gsub!(/[A-Z]+/) { |m| "_#{m.downcase}" }

        instance_variable_set("@#{var}", value)
      end
    end

    def subtotal
      items.map(&:subtotal).sum.round(2)
    end

    def total
      item_total + shipping_total
    end

    def shipping_total
      shipping_option.rate
    end

    def item_total
      items.map(&:total).sum.round(2)
    end

    def tax
      items.map(&:tax_total).sum.round(2)
    end

    def email
      shipping_person&.email || billing_person&.email
    end

    # NOTE: This may include other types of discounts,
    #       though I've not seen it yet
    def discount
      volume_discount
    end

    # discountCoupon: {
    #   id: 60747528,
    #   name: 'Customer Loyalty Appreciation',
    #   code: 'UF7QCSFL4H8E',
    #   discountType: 'PERCENT',
    #   status: 'ACTIVE',
    #   discount: 15,
    #   launchDate: '2020-05-09 04:00:00 +0000',
    #   usesLimit: 'UNLIMITED',
    #   repeatCustomerOnly: false,
    #   applicationLimit: 'UNLIMITED',
    #   creationDate: '2020-06-08 10:13:33 +0000',
    #   updateDate: '2020-05-17 09:50:18 +0000',
    #   orderCount: 0
    # }
    def coupon_discount
      items.map(&:coupon_amount).sum
    end

    def apply_coupon
      send("apply_#{coupon.type}_coupon")
    end

    def apply_percent_coupon
      items.each do |item|
        coupon_amount = item.subtotal * coupon.value / 100.0

        item.coupon_amount = coupon_amount.round(2)
      end
    end

    # discountInfo: [
    #   {
    #     value: 15,
    #     type: "PERCENT",
    #     base: "ON_TOTAL",
    #     orderTotal: 10
    #   }
    # ]
    def volume_discount
      items.map(&:discount_amount).sum
    end

    def apply_volume_discount
      send("apply_#{automatic_discount.type}_volume_discount")
    end

    def apply_percent_volume_discount
      items.each do |item|
        volume_discount_amount = (item.subtotal - item.coupon_amount) * automatic_discount.value / 100.0

        item.discounts <<= {
          discountInfo: {
            value: automatic_discount.value,
            type: 'PERCENT',
            base: 'ON_TOTAL',
            orderTotal: automatic_discount.value
          },
          total: volume_discount_amount.round(2)
        }
      end
    end

    # TODO: Handle rounding errors
    def distribute_shipping
      items.each do |item|
        shipping_per_item = shipping_option.rate.to_f / quantity

        item.shipping = (shipping_per_item * item.quantity).round(2)
      end
    end

    def apply_taxes
      items.each(&:calculate_taxes)
    end

    def quantity
      items.map(&:quantity).sum
    end

    # NOTE: Taxes are merged. Presumably if they match name/value.
    #       Also this might not be requried to place an order, then
    #       you just just use the return value after creation
    # [
    #   {
    #     name: "Tax",
    #     value: 8.75,
    #     total: 0.88
    #   },
    #   {
    #     name: "Tiny Tax",
    #     value: 1.5,
    #     total: 0.08
    #   }
    # ]
    def taxes_on_shipping
      result = []

      items.each do |item|
        item.taxes.each do |tax|
          existing_tax = result.find { |t| t[:name] == tax.name && t[:value] == tax.value }

          if existing_tax
            existing_tax[:total] += tax.tax_on_shipping
          else
            result << {
              name: tax.name,
              value: tax.value,
              total: tax.tax_on_shipping
            }
          end
        end
      end
      result
    end

    # def apply_percent_coupon(items_params)
    #   items_params.map do |item|
    #     subtotal = item[:price] * item[:quantity]
    #     discount = subtotal * coupon.value / 100.0

    #     item.to_h.merge(
    #       couponApplied: true,
    #       couponAmount: discount.round(2)
    #     )
    #   end
    # end

    # # TODO: Rounding and handling the remainder
    # def apply_amount_coupon(items_params)
    #   combined_subtotal = items_params.reduce(0) { |sum, item| sum + item[:price] * item[:quantity] }

    #   items_params.map do |item|
    #     subtotal = item[:price] * item[:quantity]
    #     discount = subtotal * coupon.value / combined_subtotal.to_f

    #     item.to_h.merge(
    #       couponApplied: true,
    #       couponAmount: discount
    #     )
    #   end
    # end

    # def apply_amount_automatic_discount(items_params)
    #   combined_subtotal = items_params.reduce(0) { |sum, item| sum + item[:price] * item[:quantity] }

    #   items_params.map do |item|
    #     subtotal = item[:price] * item[:quantity]
    #     discount = subtotal * automatic_discount.value / combined_subtotal.to_f

    #     item.to_h.merge(discounts: [{ discountInfo: {}, total: discount }])
    #   end
    # end

    # def apply_percent_automatic_discount(items_params)
    #   items_params.map do |item|
    #     subtotal = item[:price] * item[:quantity]
    #     discount = subtotal * automatic_discount.value / 100.0

    #     item.to_h.merge(
    #       discounts: [
    #         {
    #           discountInfo: {},
    #           total: discount
    #         }
    #       ]
    #     )
    #   end
    # end

    def params
      {
        subtotal: subtotal,
        total: total,
        email: email,
        paymentMethod: payment_method,
        tax: tax,
        items: items.map(&:to_h),
        shippingPerson: shipping_person.to_h,
        shippingOption: shipping_option.to_h,
        couponDiscount: coupon_discount,
        volumeDiscount: volume_discount,
        discount: discount
      }
    end

    # private

    # def make_request
    #   response = RestClient::Request.execute method: :post,
    #                                          url: "https://app.ecwid.com/api/v3/#{store_id}/orders",
    #                                          payload: params.to_json,
    #                                          headers: {
    #                                            # Params within headers form the query string
    #                                            params: { token: token },
    #                                            content_type: :json,
    #                                            accept: :json
    #                                          }

    #   @id = JSON.parse(response.body).fetch('id')
    # end
  end
end
