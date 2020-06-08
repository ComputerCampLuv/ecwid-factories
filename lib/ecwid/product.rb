# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/string'
require 'rest-client'
require 'json'

module Ecwid
  # Ecwid::Product
  class Product
    HEADERS  = { content_type: :json, accept: :json }.freeze
    BASE_URL = 'https://app.ecwid.com/api/v3/'

    attr_reader :store_id,
                :token,
                :options,
                :shipping,
                :related_products,
                :combinations,
                :wholesale_prices,
                :bulk_discounts,
                :variants,
                :id,
                :sku,
                :unlimited,
                :in_stock,
                :name,
                :name_translated,
                :price,
                :price_in_product_list,
                :default_displayed_price,
                :default_displayed_price_formatted,
                :tax,
                :is_shipping_required,
                :weight,
                :url,
                :created,
                :updated,
                :deleted,
                :create_timestamp,
                :update_timestamp,
                :product_class_id,
                :enabled,
                :warning_limit,
                :fixed_shipping_rate_only,
                :fixed_shipping_rate,
                :default_combination_id,
                :description,
                :description_translated,
                :gallery_images,
                :media,
                :category_ids,
                :categories,
                :default_category_id,
                :seo_title,
                :seo_description,
                :attributes,
                :files,
                :dimensions,
                :show_on_frontpage,
                :is_sample_product,
                :google_item_condition,
                :is_gift_card,
                :discounts_allowed

    def initialize(data = {})
      data.each do |var, value|
        instance_variable_set("@#{var}", value)
      end
    end

    def save!
      url = "#{BASE_URL}#{store_id}/products?token=#{token}"

      response = RestClient.post(url, params.to_json, HEADERS)

      @id = JSON.parse(response.body).fetch('id')

      update_variables!
    end

    def delete!
      RestClient.delete("#{BASE_URL}#{store_id}/products/#{id}?token=#{token}")

      @deleted = Time.now
    end

    def params
      {
        name: name,
        price: price,
        unlimited: unlimited,
        options: options&.map(&:to_h),
        wholesalePrices: bulk_discounts&.map(&:to_h)
      }.reject { |_k, v| v.nil? }
    end

    def price_for(quantity)
      price_for_each(quantity) * quantity
    end

    def price_for_each(quantity)
      return price unless bulk_discounts

      bulk_discounts.sort_by(&:quantity).reverse.find { |d| d.quantity <= quantity }&.price || price
    end

    def build_variants
      choices = options.select { |option| Option::MODIFIER_TYPES.include?(option.type) }.map { |option| option.choices.map { |choice| { option: option.name, choice: choice.text } } }
      combos  = choices.shift
      combos  = combos.product(choices.shift) until choices.empty?

      combos.map! do |combo|
        { options: [combo].flatten.map { |selection| { name: selection[:option], value: selection[:choice] } } }
      end

      @variants = combos.map { |combo| Variant.new(combo.merge(product: self)) }
    end

    def create_variants!
      (variants || build_variants).map(&:save!)

      update_variables!

      @variants = combinations.map { |combo| Variant.new(combo.merge(product: self)) }
    end

    private

    def update_variables!
      response = RestClient.get("#{BASE_URL}#{store_id}/products/#{id}?token=#{token}")

      data = JSON.parse(response.body)

      data.each do |var, value|
        next if [:options].include?(var)

        sc_var = var.gsub(/[A-Z]+/) { |m| "_#{m.downcase}" }

        instance_variable_set("@#{sc_var}", value)
      end
    end
  end
end

# class Product
#   HEADERS  = { content_type: :json, accept: :json }.freeze
#   BASE_URL = 'https://app.ecwid.com/api/v3/'

#   attr_accessor :id, :store_id, :token, :name,
#                 :unlimited, :base_price, :options,
#                 :bulk_discounts, :variants

#   def save!
#     url = "#{BASE_URL}#{store_id}/products?token=#{token}"

#     response = RestClient.post(url, params.to_json, HEADERS)

#     @id = JSON.parse(response.body).fetch('id')

#     create_variants if variants

#     @data = fetch_product
#   end
# end

# {
#   "id": 206834300,
#   "sku": "00051",
#   "unlimited": true,
#   "inStock": true,
#   "name": "Uber Item",
#   "nameTranslated": {
#       "en": "Uber Item"
#   },
#   "price": 10,
#   "priceInProductList": 10,
#   "defaultDisplayedPrice": 10,
#   "defaultDisplayedPriceFormatted": "$10.00",
#   "tax": {
#       "taxable": true,
#       "defaultLocationIncludedTaxRate": 0,
#       "enabledManualTaxes": [
#           1156337156,
#           553820111
#       ]
#   },
#   "wholesalePrices": [
#       {
#           "quantity": 2,
#           "price": 9
#       },
#       {
#           "quantity": 5,
#           "price": 8
#       }
#   ],
#   "isShippingRequired": true,
#   "weight": 0,
#   "url": "https://store29229076.shopsettings.com/Uber-Item-p206834300",
#   "created": "2020-06-07 11:22:23 +0000",
#   "updated": "2020-06-07 11:27:45 +0000",
#   "createTimestamp": 1591528943,
#   "updateTimestamp": 1591529265,
#   "productClassId": 0,
#   "enabled": true,
#   "options": [
#       {
#           "type": "SELECT",
#           "name": "Drop-down List",
#           "nameTranslated": {
#               "en": "Drop-down List"
#           },
#           "choices": [
#               {
#                   "text": "dd value 1",
#                   "textTranslated": {
#                       "en": "dd value 1"
#                   },
#                   "priceModifier": 0,
#                   "priceModifierType": "ABSOLUTE"
#               },
#               {
#                   "text": "dd value 2",
#                   "textTranslated": {
#                       "en": "dd value 2"
#                   },
#                   "priceModifier": 1,
#                   "priceModifierType": "ABSOLUTE"
#               },
#               {
#                   "text": "dd value 3",
#                   "textTranslated": {
#                       "en": "dd value 3"
#                   },
#                   "priceModifier": 2,
#                   "priceModifierType": "ABSOLUTE"
#               }
#           ],
#           "defaultChoice": 0,
#           "required": false
#       },
#       {
#           "type": "RADIO",
#           "name": "Radio Buttons",
#           "nameTranslated": {
#               "en": "Radio Buttons"
#           },
#           "choices": [
#               {
#                   "text": "rb value 1",
#                   "textTranslated": {
#                       "en": "rb value 1"
#                   },
#                   "priceModifier": 0,
#                   "priceModifierType": "ABSOLUTE"
#               },
#               {
#                   "text": "rb value 2",
#                   "textTranslated": {
#                       "en": "rb value 2"
#                   },
#                   "priceModifier": -15,
#                   "priceModifierType": "PERCENT"
#               },
#               {
#                   "text": "rb value 3",
#                   "textTranslated": {
#                       "en": "rb value 3"
#                   },
#                   "priceModifier": 2.5,
#                   "priceModifierType": "ABSOLUTE"
#               }
#           ],
#           "defaultChoice": 0,
#           "required": false
#       },
#       {
#           "type": "TEXTFIELD",
#           "name": "Text Field",
#           "nameTranslated": {
#               "en": "Text Field"
#           },
#           "required": false
#       }
#   ],
#   "warningLimit": 0,
#   "fixedShippingRateOnly": false,
#   "fixedShippingRate": 0,
#   "shipping": {
#       "type": "GLOBAL_METHODS",
#       "methodMarkup": 0,
#       "flatRate": 0,
#       "disabledMethods": [],
#       "enabledMethods": []
#   },
#   "defaultCombinationId": 82502899,
#   "description": "",
#   "descriptionTranslated": {
#       "en": ""
#   },
#   "galleryImages": [],
#   "media": {
#       "images": []
#   },
#   "categoryIds": [],
#   "categories": [],
#   "defaultCategoryId": 0,
#   "seoTitle": "",
#   "seoDescription": "",
#   "attributes": [],
#   "files": [],
#   "relatedProducts": {
#       "productIds": [],
#       "relatedCategory": {
#           "enabled": false,
#           "categoryId": 0,
#           "productCount": 5
#       }
#   },
#   "combinations": [
#       {
#           "id": 82502891,
#           "combinationNumber": 9,
#           "options": [
#               {
#                   "name": "Drop-down List",
#                   "nameTranslated": {
#                       "en": "Drop-down List"
#                   },
#                   "value": "dd value 3",
#                   "valueTranslated": {
#                       "en": "dd value 3"
#                   }
#               },
#               {
#                   "name": "Radio Buttons",
#                   "nameTranslated": {
#                       "en": "Radio Buttons"
#                   },
#                   "value": "rb value 3",
#                   "valueTranslated": {
#                       "en": "rb value 3"
#                   }
#               }
#           ],
#           "unlimited": true,
#           "warningLimit": 0,
#           "attributes": [],
#           "defaultDisplayedPrice": 14.5,
#           "defaultDisplayedPriceFormatted": "$14.50"
#       },
#       {
#           "id": 82502892,
#           "combinationNumber": 8,
#           "options": [
#               {
#                   "name": "Drop-down List",
#                   "nameTranslated": {
#                       "en": "Drop-down List"
#                   },
#                   "value": "dd value 3",
#                   "valueTranslated": {
#                       "en": "dd value 3"
#                   }
#               },
#               {
#                   "name": "Radio Buttons",
#                   "nameTranslated": {
#                       "en": "Radio Buttons"
#                   },
#                   "value": "rb value 2",
#                   "valueTranslated": {
#                       "en": "rb value 2"
#                   }
#               }
#           ],
#           "unlimited": true,
#           "warningLimit": 0,
#           "attributes": [],
#           "defaultDisplayedPrice": 10.5,
#           "defaultDisplayedPriceFormatted": "$10.50"
#       },
#       {
#           "id": 82502893,
#           "combinationNumber": 7,
#           "options": [
#               {
#                   "name": "Drop-down List",
#                   "nameTranslated": {
#                       "en": "Drop-down List"
#                   },
#                   "value": "dd value 3",
#                   "valueTranslated": {
#                       "en": "dd value 3"
#                   }
#               },
#               {
#                   "name": "Radio Buttons",
#                   "nameTranslated": {
#                       "en": "Radio Buttons"
#                   },
#                   "value": "rb value 1",
#                   "valueTranslated": {
#                       "en": "rb value 1"
#                   }
#               }
#           ],
#           "unlimited": true,
#           "warningLimit": 0,
#           "attributes": [],
#           "defaultDisplayedPrice": 12,
#           "defaultDisplayedPriceFormatted": "$12.00"
#       },
#       {
#           "id": 82502894,
#           "combinationNumber": 6,
#           "options": [
#               {
#                   "name": "Drop-down List",
#                   "nameTranslated": {
#                       "en": "Drop-down List"
#                   },
#                   "value": "dd value 2",
#                   "valueTranslated": {
#                       "en": "dd value 2"
#                   }
#               },
#               {
#                   "name": "Radio Buttons",
#                   "nameTranslated": {
#                       "en": "Radio Buttons"
#                   },
#                   "value": "rb value 3",
#                   "valueTranslated": {
#                       "en": "rb value 3"
#                   }
#               }
#           ],
#           "unlimited": true,
#           "warningLimit": 0,
#           "attributes": [],
#           "defaultDisplayedPrice": 13.5,
#           "defaultDisplayedPriceFormatted": "$13.50"
#       },
#       {
#           "id": 82502895,
#           "combinationNumber": 5,
#           "options": [
#               {
#                   "name": "Drop-down List",
#                   "nameTranslated": {
#                       "en": "Drop-down List"
#                   },
#                   "value": "dd value 2",
#                   "valueTranslated": {
#                       "en": "dd value 2"
#                   }
#               },
#               {
#                   "name": "Radio Buttons",
#                   "nameTranslated": {
#                       "en": "Radio Buttons"
#                   },
#                   "value": "rb value 2",
#                   "valueTranslated": {
#                       "en": "rb value 2"
#                   }
#               }
#           ],
#           "unlimited": true,
#           "warningLimit": 0,
#           "attributes": [],
#           "defaultDisplayedPrice": 9.5,
#           "defaultDisplayedPriceFormatted": "$9.50"
#       },
#       {
#           "id": 82502896,
#           "combinationNumber": 4,
#           "options": [
#               {
#                   "name": "Drop-down List",
#                   "nameTranslated": {
#                       "en": "Drop-down List"
#                   },
#                   "value": "dd value 2",
#                   "valueTranslated": {
#                       "en": "dd value 2"
#                   }
#               },
#               {
#                   "name": "Radio Buttons",
#                   "nameTranslated": {
#                       "en": "Radio Buttons"
#                   },
#                   "value": "rb value 1",
#                   "valueTranslated": {
#                       "en": "rb value 1"
#                   }
#               }
#           ],
#           "unlimited": true,
#           "warningLimit": 0,
#           "attributes": [],
#           "defaultDisplayedPrice": 11,
#           "defaultDisplayedPriceFormatted": "$11.00"
#       },
#       {
#           "id": 82502897,
#           "combinationNumber": 3,
#           "options": [
#               {
#                   "name": "Drop-down List",
#                   "nameTranslated": {
#                       "en": "Drop-down List"
#                   },
#                   "value": "dd value 1",
#                   "valueTranslated": {
#                       "en": "dd value 1"
#                   }
#               },
#               {
#                   "name": "Radio Buttons",
#                   "nameTranslated": {
#                       "en": "Radio Buttons"
#                   },
#                   "value": "rb value 3",
#                   "valueTranslated": {
#                       "en": "rb value 3"
#                   }
#               }
#           ],
#           "unlimited": true,
#           "warningLimit": 0,
#           "attributes": [],
#           "defaultDisplayedPrice": 12.5,
#           "defaultDisplayedPriceFormatted": "$12.50"
#       },
#       {
#           "id": 82502898,
#           "combinationNumber": 2,
#           "options": [
#               {
#                   "name": "Drop-down List",
#                   "nameTranslated": {
#                       "en": "Drop-down List"
#                   },
#                   "value": "dd value 1",
#                   "valueTranslated": {
#                       "en": "dd value 1"
#                   }
#               },
#               {
#                   "name": "Radio Buttons",
#                   "nameTranslated": {
#                       "en": "Radio Buttons"
#                   },
#                   "value": "rb value 2",
#                   "valueTranslated": {
#                       "en": "rb value 2"
#                   }
#               }
#           ],
#           "unlimited": true,
#           "warningLimit": 0,
#           "attributes": [],
#           "defaultDisplayedPrice": 8.5,
#           "defaultDisplayedPriceFormatted": "$8.50"
#       },
#       {
#           "id": 82502899,
#           "combinationNumber": 1,
#           "options": [
#               {
#                   "name": "Drop-down List",
#                   "nameTranslated": {
#                       "en": "Drop-down List"
#                   },
#                   "value": "dd value 1",
#                   "valueTranslated": {
#                       "en": "dd value 1"
#                   }
#               },
#               {
#                   "name": "Radio Buttons",
#                   "nameTranslated": {
#                       "en": "Radio Buttons"
#                   },
#                   "value": "rb value 1",
#                   "valueTranslated": {
#                       "en": "rb value 1"
#                   }
#               }
#           ],
#           "unlimited": true,
#           "warningLimit": 0,
#           "attributes": [],
#           "defaultDisplayedPrice": 10,
#           "defaultDisplayedPriceFormatted": "$10.00"
#       }
#   ],
#   "dimensions": {
#       "length": 0,
#       "width": 0,
#       "height": 0
#   },
#   "showOnFrontpage": 61,
#   "isSampleProduct": false,
#   "googleItemCondition": "NEW",
#   "isGiftCard": false,
#   "discountsAllowed": true
# }
