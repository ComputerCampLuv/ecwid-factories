# frozen_string_literal: true

require 'tax'

RSpec.describe Ecwid::Tax do
  let(:tax) { build :ecwid_tax, value: 8.75 }

  describe '#decimal_rate' do
    it 'should return a decimal of the percentage tax rate' do
      expect(tax.decimal_rate).to eq(0.0875)
    end
  end

  describe '#calulate_for' do
    let(:product) { build :ecwid_product, price: 10 }

    it 'should return a hash with the calculated tax data' do
      expect(tax.calculate_for(product, 1)).to eq(
        includeInPrice: false,
        name: tax.name,
        taxOnDiscountedSubtotal: 0.88,
        taxOnShipping: 0,
        total: 0.88,
        value: 8.75
      )
    end
  end
end
