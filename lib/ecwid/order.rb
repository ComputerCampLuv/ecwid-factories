# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/string'
require 'rest-client'
require 'json'

# {
#   "vendorOrderNumber": "270",
#   "refundedAmount": 0,
#   "subtotal": 21.4,
#   "total": 23.27,
#   "giftCardRedemption": 0,
#   "totalBeforeGiftCardRedemption": 23.27,
#   "email": "msangster@shopkeep.com",
#   "paymentMethod": "Pay by cash",
#   "tax": 1.87,
#   "customerTaxExempt": false,
#   "customerTaxId": "",
#   "customerTaxIdValid": false,
#   "reversedTaxApplied": false,
#   "ipAddress": "81.155.73.251",
#   "couponDiscount": 0,
#   "paymentStatus": "AWAITING_PAYMENT",
#   "fulfillmentStatus": "AWAITING_PROCESSING",
#   "orderNumber": 270,
#   "refererUrl": "https://store29229076.shopsettings.com/",
#   "orderComments": "",
#   "volumeDiscount": 0,
#   "customerId": 71297887,
#   "membershipBasedDiscount": 0,
#   "totalAndMembershipBasedDiscount": 0,
#   "discount": 0,
#   "usdTotal": 23.27,
#   "globalReferer": "https://app.ecwid.com/api/v3/29229076/products?token=secret_cNhdYsQXz7JAbwBZF9sV9tEvckyVLbAr&enabled=false&limit=1",
#   "createDate": "2020-06-05 20:48:32 +0000",
#   "updateDate": "2020-06-05 20:48:32 +0000",
#   "createTimestamp": 1591390112,
#   "updateTimestamp": 1591390112,
#   "items": [
#       {
#           "id": 334934802,
#           "productId": 206653686,
#           "categoryId": 0,
#           "price": 10.7,
#           "productPrice": 10,
#           "sku": "00050",
#           "quantity": 2,
#           "shortDescription": "",
#           "shortDescriptionTranslated": {
#               "en": ""
#           },
#           "tax": 1.87,
#           "shipping": 0,
#           "quantityInStock": 0,
#           "name": "The Dark Side",
#           "nameTranslated": {
#               "en": "The Dark Side"
#           },
#           "isShippingRequired": true,
#           "weight": 0,
#           "trackQuantity": false,
#           "fixedShippingRateOnly": false,
#           "fixedShippingRate": 0,
#           "digital": false,
#           "productAvailable": true,
#           "couponApplied": false,
#           "selectedOptions": [
#               {
#                   "name": "Drop Down List",
#                   "nameTranslated": {
#                       "en": "Drop Down List"
#                   },
#                   "value": "Option Value 2",
#                   "valueTranslated": {
#                       "en": "Option Value 2"
#                   },
#                   "valuesArray": [
#                       "Option Value 2"
#                   ],
#                   "selections": [
#                       {
#                           "selectionTitle": "Option Value 2",
#                           "selectionModifier": 13,
#                           "selectionModifierType": "PERCENT"
#                       }
#                   ],
#                   "type": "CHOICE"
#               },
#               {
#                   "name": "Checkboxes",
#                   "nameTranslated": {
#                       "en": "Checkboxes"
#                   },
#                   "value": "Option Value 1, Option Value 2",
#                   "valuesArray": [
#                       "Option Value 1",
#                       "Option Value 2"
#                   ],
#                   "selections": [
#                       {
#                           "selectionTitle": "Option Value 1",
#                           "selectionModifier": -5.5,
#                           "selectionModifierType": "PERCENT"
#                       },
#                       {
#                           "selectionTitle": "Option Value 2",
#                           "selectionModifier": 2.1,
#                           "selectionModifierType": "ABSOLUTE"
#                       }
#                   ],
#                   "type": "CHOICES"
#               }
#           ],
#           "taxes": [
#               {
#                   "name": "Tax",
#                   "value": 8.75,
#                   "total": 1.87,
#                   "taxOnDiscountedSubtotal": 1.87,
#                   "taxOnShipping": 0,
#                   "includeInPrice": false
#               }
#           ],
#           "dimensions": {
#               "length": 0,
#               "width": 0,
#               "height": 0
#           },
#           "discountsAllowed": true,
#           "taxable": true,
#           "isGiftCard": false
#       }
#   ],
#   "refunds": [],
#   "billingPerson": {
#       "name": "Marc Sangster",
#       "firstName": "Marc",
#       "lastName": "Sangster",
#       "street": "1",
#       "city": "Yemen Street",
#       "countryCode": "GB",
#       "countryName": "United Kingdom",
#       "postalCode": "BT1 1AA",
#       "stateOrProvinceCode": "Yemen",
#       "stateOrProvinceName": "Yemen"
#   },
#   "shippingPerson": {
#       "name": "Marc Sangster",
#       "firstName": "Marc",
#       "lastName": "Sangster"
#   },
#   "shippingOption": {
#       "shippingMethodName": "Self Pickup",
#       "shippingRate": 0,
#       "isPickup": true,
#       "pickupInstruction": "<p><strong>Pickup location</strong></p><p>PlipPlopPlup, 1 Yemen Steet, Yemen</p><p><strong>Business hours</strong></p><p>All Day, Everyday</p>",
#       "fulfillmentType": "PICKUP"
#   },
#   "handlingFee": {
#       "value": 0
#   },
#   "predictedPackage": [],
#   "shipments": [],
#   "additionalInfo": {
#       "google_customer_id": "2026495402.1588169630"
#   },
#   "paymentParams": {},
#   "hidden": false,
#   "taxesOnShipping": [],
#   "acceptMarketing": false,
#   "disableAllCustomerNotifications": false,
#   "externalFulfillment": false
# }

  # "billingPerson": {
  #     "name": "Marc Sangster",
  #     "firstName": "Marc",
  #     "lastName": "Sangster",
  #     "street": "1",
  #     "city": "Yemen Street",
  #     "countryCode": "GB",
  #     "countryName": "United Kingdom",
  #     "postalCode": "BT1 1AA",
  #     "stateOrProvinceCode": "Yemen",
  #     "stateOrProvinceName": "Yemen"
  # },

  # "shippingPerson": {
  #     "name": "Marc Sangster",
  #     "firstName": "Marc",
  #     "lastName": "Sangster"
  # },

  # "shippingOption": {
  #     "shippingMethodName": "Self Pickup",
  #     "shippingRate": 0,
  #     "isPickup": true,
  #     "pickupInstruction": "<p><strong>Pickup location</strong></p><p>PlipPlopPlup, 1 Yemen Steet, Yemen</p><p><strong>Business hours</strong></p><p>All Day, Everyday</p>",
  #     "fulfillmentType": "PICKUP"
  # }

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
                # :subtotal,
                # :total,
                :gift_card_redemption,
                :total_before_gift_card_redemption,
                # :email,
                :payment_method,
                # :tax,
                :customer_tax_exempt,
                :customer_tax_id,
                :customer_tax_id_valid,
                :reversed_tax_applied,
                :ip_address,
                :coupon,
                # :coupon_discount,
                :payment_status,
                :fulfillment_status,
                :order_number,
                :referer_url,
                :order_comments,
                # :volume_discount,
                :customer_id,
                :membership_based_discount,
                :total_and_membership_based_discount,
                # :discount,
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
                :taxes_on_shipping,
                :accept_marketing,
                :disable_all_customer_notifications,
                :external_fulfillment

    def initialize(data = {})
      data.each do |var, value|
        instance_variable_set("@#{var}", value)
      end
      # INFO: Order is important. Coupon should be applied first
      apply_coupon if coupon
      apply_volume_discount if automatic_discount
    end

    def update_variables(data = {})
      data.each do |var, value|
        var.gsub!(/[A-Z]+/) { |m| "_#{m.downcase}" }

        instance_variable_set("@#{var}", value)
      end
    end

    # TODO: Shippig and Discounts
    def subtotal
      items.map(&:subtotal).sum.round(2)
    end

    # TODO: Shippig and Discounts
    # (line_items.map(&:total).sum + shipping.rate - discount_total).round(2),
    def total
      items.map(&:total).sum.round(2)
    end

    def tax
      items.map(&:tax_total).sum.round(2)
    end

    def email
      shipping_person&.email || billing_person&.email
    end

    # NOTE: This may include other types of discounts though I've not seen it yet
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

    # def save!
    #   make_request
    # end

    # def items
    #   items_params = line_items.map(&:to_h)

    #   items_params = send("apply_#{coupon.type}_coupon", items_params) if coupon
    #   items_params = send("apply_#{automatic_discount.type}_automatic_discount", items_params) if automatic_discount

    #   items_params
    # end

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

    # def coupon_discount
    #   items.map { |item| item[:couponAmount] || 0 }.sum
    # end

    # def automatic_discount_amount
    #   if automatic_discount&.type == :amount
    #     automatic_discount.value
    #   elsif automatic_discount&.type == :percent
    #     items.map { |i| i[:discounts].map { |d| d[:total] } }.flatten.sum
    #   else
    #     0
    #   end
    # end

    # def discount_total
    #   # plus some other things
    #   coupon_discount + automatic_discount_amount
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

    # def params
    #   {
    #     subtotal: subtotal,
    #     total: (line_items.map(&:total).sum + shipping.rate - discount_total).round(2),
    #     email: customer.email,
    #     paymentMethod: payment_method,
    #     tax: line_items.map(&:tax_total).sum.round(2),
    #     customerTaxExempt: false,
    #     customerTaxId: '',
    #     customerTaxIdValid: false,
    #     reversedTaxApplied: false,
    #     volumeDiscount: automatic_discount_amount,
    #     # discount: automatic_discount_amount,
    #     predictedPackage: [],
    #     taxesOnShipping: [],
    #     items: items,
    #     # I don't think this matters
    #     shippingPerson: shipping.pick_up ? customer.partial : customer.full,
    #     shippingOption: shipping.to_h,
    #     couponDiscount: coupon_discount
    #   }
    # end

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
