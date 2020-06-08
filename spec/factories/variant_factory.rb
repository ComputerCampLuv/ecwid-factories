# frozen_string_literal: true

FactoryBot.define do
  factory :ecwid_variant, class: Ecwid::Variant do
    transient do
      product_options { build_list(:ecwid_option, 1) }
      option          { product_options.first }
      choice          { option.choices.first }
    end
    store_id   { ENV.fetch('ECWID_STORE_ID') }
    token      { ENV.fetch('ECWID_TOKEN') }
    product    { build :ecwid_product, options: product_options }
    options    { [{ name: option.name, value: choice.text }] }

    initialize_with do
      new product: product,
          store_id: store_id,
          token: token,
          options: options
    end
  end
end
