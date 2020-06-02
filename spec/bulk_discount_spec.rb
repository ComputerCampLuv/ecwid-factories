# frozen_string_literal: true

require 'bulk_discount'

RSpec.describe Ecwid::BulkDiscount do
  let(:discount) { build :ecwid_bulk_discount, quantity: 2, price: 8 }

  describe '#to_h' do
    it 'should return valid hash' do
      expect(discount.to_h).to eq(
        quantity: 2,
        price: 8
      )
    end
  end
end
