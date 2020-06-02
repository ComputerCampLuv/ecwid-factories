# frozen_string_literal: true

RSpec.describe Ecwid::LineItem do
  # let(:line_item) { build :ecwid_line_item, product: product }
  # let(:product)   { build :ecwid_product, price: 10 }

  describe '#subtotal' do
    context 'when the line item has a quantity of 1 and no tax' do
      let(:line_item) { build :ecwid_line_item, product: product }
      let(:product)   { build :ecwid_product, price: 10 }

      it 'should return the correct subtotal' do
        expect(line_item.subtotal).to eq(10)
      end
    end

    context 'when the line item has a quantity of 2 and no tax' do
      let(:line_item) { build :ecwid_line_item, product: product, quantity: 2 }
      let(:product)   { build :ecwid_product, price: 10 }

      it 'should return the correct subtotal' do
        expect(line_item.subtotal).to eq(20)
      end
    end

    context 'when the line item has a quantity of 1 and includes a single tax' do
      let(:line_item) { build :ecwid_line_item, product: product }
      let(:product)   { build :ecwid_product, price: 10 }
      let(:tax)       { build :ecwid_tax }

      it "should return the correct subtotal that doesn't include tax" do
        expect(line_item.subtotal).to eq(10)
      end
    end
  end

  describe '#total' do
    context 'when the line item has a quantity of 1 and no tax' do
      let(:line_item) { build :ecwid_line_item, product: product }
      let(:product)   { build :ecwid_product, price: 10 }

      it 'should return the correct total' do
        expect(line_item.total).to eq(10)
      end
    end

    context 'when the line item has a quantity of 2 and no tax' do
      let(:line_item) { build :ecwid_line_item, product: product, quantity: 2 }
      let(:product)   { build :ecwid_product, price: 10 }

      it 'should return the correct total' do
        expect(line_item.total).to eq(20)
      end
    end

    context 'when the line item has a quantity of 1 and includes a single tax' do
      let(:line_item) { build :ecwid_line_item, product: product }
      let(:product)   { build :ecwid_product, price: 10 }
      let(:tax)       { build :ecwid_tax, value: 15 }

      it 'should return the correct total' do
        expect(line_item.total).to eq(10)
      end
    end
  end

  describe '#tax_total' do; end
  describe '#tax_params' do; end
  describe '#to_h' do; end
end
