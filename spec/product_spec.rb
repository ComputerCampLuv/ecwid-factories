# frozen_string_literal: true

require 'product'

RSpec.describe Ecwid::Product do
  describe '#params' do
    context 'when product has no options' do
      let(:product) { build :ecwid_product }

      it 'should return valid product params' do
        expect(product.params).to eq(
          name: product.name,
          price: product.price,
          unlimited: product.unlimited
        )
      end
    end

    context 'when product has a single option' do
      let(:product) { build :ecwid_product, options: options }
      let(:options) { build_list(:ecwid_option, 1) }

      it 'should return valid product params' do
        expect(product.params).to eq(
          name: product.name,
          price: product.price,
          unlimited: product.unlimited,
          options: options.map(&:to_h)
        )
      end
    end

    context 'when product has all the options' do
      let(:product)   { build :ecwid_product, options: options }
      let(:options)   { [drop_down, radio, size, checkbox, textfield, textarea, date, files] }
      let(:drop_down) { build :ecwid_option, :drop_down }
      let(:radio)     { build :ecwid_option, :radio }
      let(:size)      { build :ecwid_option, :size }
      let(:checkbox)  { build :ecwid_option, :checkbox }
      let(:textfield) { build :ecwid_option, :text_field }
      let(:textarea)  { build :ecwid_option, :text_area }
      let(:date)      { build :ecwid_option, :date }
      let(:files)     { build :ecwid_option, :files }

      it 'should return valid product params' do
        expect(product.params).to eq(
          name: product.name,
          price: product.price,
          unlimited: product.unlimited,
          options: options.map(&:to_h)
        )
      end
    end

    context 'when product has a bulk discount' do
      let(:product)   { build :ecwid_product, price: 10, bulk_discounts: discounts }
      let(:discounts) { build_list(:ecwid_bulk_discount, 1, quantity: 2, price: 9) }

      it 'should return valid product params' do
        expect(product.params).to eq(
          name: product.name,
          price: 10,
          unlimited: product.unlimited,
          wholesalePrices: discounts.map(&:to_h)
        )
      end
    end

    context 'when product has variants' do
      let(:product)  { build :ecwid_product, variants: true, options: options }
      let(:variants) { product.combinations }

      context 'when product has a single option with 3 values' do
        let(:options) { build_list(:ecwid_option, 1) }

        it 'should return valid product params' do
          expect(variants.count).to eq(3)

          variants.each do |variant|
            variant_options = variant.fetch :options

            expect(variant_options.count).to eq(1)
            expect(variant_options).to all(
              (be_a(Hash).and include(:name, :value))
            )
          end
        end
      end

      context 'when product has 2 options with 3 values each' do
        let(:options) { build_list(:ecwid_option, 2) }

        it 'should return valid product params' do
          expect(variants.count).to eq(9)

          variants.each do |variant|
            variant_options = variant.fetch :options

            expect(variant_options.count).to eq(2)
            expect(variant_options).to all(
              (be_a(Hash).and include(:name, :value))
            )
          end
        end
      end

      context 'when product has 3 options with 3 values each' do
        let(:options) { build_list(:ecwid_option, 3) }

        it 'should return valid product params' do
          expect(variants.count).to eq(27)

          variants.each do |variant|
            variant_options = variant.fetch :options

            expect(variant_options.count).to eq(3)
            expect(variant_options).to all(
              (be_a(Hash).and include(:name, :value))
            )
          end
        end
      end
    end
  end
end
