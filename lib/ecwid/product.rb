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

    attr_accessor :id, :store_id, :token, :name, :unlimited,
                  :price, :options, :bulk_discounts, :variants

    def save!
      url = "#{BASE_URL}#{store_id}/products?token=#{token}"

      response = RestClient.post(url, params.to_json, HEADERS)

      @id = JSON.parse(response.body).fetch('id')

      create_variants if variants

      @data = fetch_product
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

    def delete!
      RestClient.delete("#{BASE_URL}#{store_id}/products/#{id}?token=#{token}")
    end

    def data
      @data ||= fetch_product
    end

    def create_variants
      combinations.each do |combo|
        url = "#{BASE_URL}#{store_id}/products/#{id}/combinations?token=#{token}"

        RestClient.post(url, combo.to_json, HEADERS)
      end
    end

    def combinations
      return [] unless variants

      choices = options.select { |option| Option::MODIFIER_TYPES.include?(option.type) }.map { |option| option.choices.map { |choice| { option: option.name, choice: choice.text } } }
      combos  = choices.shift
      combos  = combos.product(choices.shift) until choices.empty?

      combos.map { |combo| { options: [combo].flatten.map { |selection| { name: selection[:option], value: selection[:choice] } } } }
    end

    private

    def fetch_product
      return {} if id.nil?

      response = RestClient.get("#{BASE_URL}#{store_id}/products/#{id}?token=#{token}")

      JSON.parse(response.body).deep_symbolize_keys
    end

    def method_missing(method, *_args, &_block)
      super unless data.keys.include?(method)

      data.fetch(method)
    end

    def respond_to_missing?(method, *_args, &_block)
      data.keys.include?(method) || super
    end
  end
end
