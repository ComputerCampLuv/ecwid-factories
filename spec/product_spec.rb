# frozen_string_literal: true

RSpec.describe Ecwid::Product do
  # let(:store_id) { ENV.fetch('ECWID_STORE_ID') }
  # let(:token)    { ENV.fetch('ECWID_TOKEN') }

  # describe '#save!' do
  #   before do
  #     product.save!
  #   end

  #   after do
  #     product.delete!
  #   end

  #   context 'when the product is basic' do
  #     let(:name)  { "Basic Product #{SecureRandom.hex(2)}" }
  #     let(:price) { rand(100..5000) / 100.0 }
  #     let(:product) do
  #       subject.class.new store_id: store_id,
  #                         token: token,
  #                         name: name,
  #                         price: price
  #     end

  #     it 'will save the item and populate variables', :aggregate_failures do
  #       expect(product.id).to be_an(Integer)
  #       expect(product.name).to eq(name)
  #       expect(product.price).to eq(price)
  #     end
  #   end

  #   context 'when the product is includes a bulk discount' do
  #     let(:name)     { "Bulk Discount Product #{SecureRandom.hex(2)}" }
  #     let(:price)    { 10 }
  #     let(:discount) { build :ecwid_bulk_discount, quantity: 2, price: 7.5 }
  #     let(:product) do
  #       subject.class.new store_id: store_id,
  #                         token: token,
  #                         name: name,
  #                         price: price,
  #                         bulk_discounts: [discount]
  #     end

  #     it 'will save the item and populate variables', :aggregate_failures do
  #       expect(product.id).to be_an(Integer)
  #       expect(product.name).to eq(name)
  #       expect(product.price).to eq(price)
  #       expect(product.price_for_each(discount.quantity)).to eq(discount.price)
  #       expect(product.wholesale_prices).to include(
  #         'quantity' => discount.quantity,
  #         'price' => discount.price
  #       )
  #     end
  #   end
  # end

  describe '#price_for' do
    context 'when product has no bulk discount' do
      let(:product) { build :ecwid_product, price: 10 }

      it 'should return the product price' do
        expect(product.price_for(1)).to eq(10)
      end

      it 'should return the product price multiplied by the quantity' do
        expect(product.price_for(4)).to eq(40)
      end
    end

    context 'when product has a bulk discount' do
      let(:product)  { build :ecwid_product, price: 10, bulk_discounts: [discount] }
      let(:discount) { build :ecwid_bulk_discount, quantity: 2, price: 8 }

      context 'when the threshold for the discount is met' do
        it 'should return the bulk discount price multiplied by the quantity' do
          expect(product.price_for(2)).to eq(16)
        end
      end

      context 'when the threshold for the discount is not met' do
        it 'should return the product price' do
          expect(product.price_for(1)).to eq(10)
        end
      end
    end
  end

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
      let(:product)  { build :ecwid_product, options: options }
      let(:variants) { product.variants}

      before do
        product.build_variants
      end

      context 'when product has a single option with 3 values' do
        let(:options) { build_list(:ecwid_option, 1) }

        it 'should return valid product params' do
          expect(variants.count).to eq(3)

          variants.each do |variant|
            expect(variant.options.count).to eq(1)
            expect(variant.options).to all(
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
            expect(variant.options.count).to eq(2)
            expect(variant.options).to all(
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
            expect(variant.options.count).to eq(3)
            expect(variant.options).to all(
              (be_a(Hash).and include(:name, :value))
            )
          end
        end
      end
    end
  end
end
