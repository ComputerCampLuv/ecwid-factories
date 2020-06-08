# frozen_string_literal: true

module Ecwid
  # Ecwid::Variant
  class Variant
    HEADERS  = { content_type: :json, accept: :json }.freeze
    BASE_URL = 'https://app.ecwid.com/api/v3/'

    attr_reader :store_id,
                :token,
                :product,
                :id,
                :combination_number,
                :options,
                :unlimited,
                :warning_limit,
                :attributes,
                :default_displayed_price,
                :default_displayed_price_formatted

    def initialize(data = {})
      data.each do |var, value|
        instance_variable_set("@#{var}", value)
      end
    end

    def save!
      url = "#{BASE_URL}#{store_id}/products/#{product.id}/combinations?token=#{token}"

      repsonse = RestClient.post(url, params.to_json, HEADERS)

      @id = JSON.parse(repsonse.body).fetch('id')
    end

    def params
      { options: options }
    end
  end
end

# {
#   "id": 82502891,
#   "combinationNumber": 9,
#   "options": [
#       {
#           "name": "Drop-down List",
#           "nameTranslated": {
#               "en": "Drop-down List"
#           },
#           "value": "dd value 3",
#           "valueTranslated": {
#               "en": "dd value 3"
#           }
#       },
#       {
#           "name": "Radio Buttons",
#           "nameTranslated": {
#               "en": "Radio Buttons"
#           },
#           "value": "rb value 3",
#           "valueTranslated": {
#               "en": "rb value 3"
#           }
#       }
#   ],
#   "unlimited": true,
#   "warningLimit": 0,
#   "attributes": [],
#   "defaultDisplayedPrice": 14.5,
#   "defaultDisplayedPriceFormatted": "$14.50"
# },
