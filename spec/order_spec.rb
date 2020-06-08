# frozen_string_literal: true

RSpec.describe Ecwid::Order do
  before do
    allow(product).to receive(:id).and_return(1)
    allow(product).to receive(:sku).and_return('101')
    allow(product).to receive(:discounts_allowed).and_return(true)
    allow(product).to receive(:is_gift_card).and_return(false)
    allow(product).to receive(:tax).and_return(taxable: true)
  end

  describe 'item with mad modifiers' do
    let(:order)      { build :ecwid_order, items: [line_item] }
    let(:line_item)  { build :ecwid_line_item, product: product, quantity: 2, selections: selections }
    let(:product)    { build :ecwid_product, price: 10, options: [option1, option2], bulk_discounts: [discount] }
    let(:discount)   { build :ecwid_bulk_discount, price: 8, quantity: 2 }
    let(:option1)    { build :ecwid_option, :radio, choices: [choice1] }
    let(:option2)    { build :ecwid_option, :checkbox, choices: [choice2, choice3] }
    let(:choice1)    { build :ecwid_choice, type: 'PERCENT', value: 13 }
    let(:choice2)    { build :ecwid_choice, type: 'PERCENT', value: -5.5 }
    let(:choice3)    { build :ecwid_choice, type: 'ABSOLUTE', value: 2.1 }
    let(:selections) do
      [
        { name: option1.name, value: choice1.text },
        { name: option2.name, values: [choice2.text, choice3.text] }
      ]
    end

    it "shouldn't shit the bed", :aggregate_failures do
      expect(order.total).to eq(21.4)
      expect(order.subtotal).to eq(21.4)
      expect(order.params).to include(
        total: 21.4,
        subtotal: 21.4
      )
    end
  end

  describe 'order with coupon discounts' do
    let(:order)     { build :ecwid_order, items: [line_item], coupon: coupon }
    let(:line_item) { build :ecwid_line_item, product: product }
    let(:product)   { build :ecwid_product, price: 10 }
    let(:coupon)    { build :ecwid_coupon, type: :percent, value: 18 }

    it "shouldn't shit the bed", :aggregate_failures do
      expect(order.total).to eq(8.2)
      expect(order.subtotal).to eq(10)
      expect(order.coupon_discount).to eq(1.8)
      expect(order.params).to include(
        total: 8.2,
        subtotal: 10,
        couponDiscount: 1.8
      )
    end
  end

  describe 'bulk, coupon, and voulume discount' do
    let(:order)     { build :ecwid_order, items: [line_item], coupon: coupon, automatic_discount: automatic }
    let(:line_item) { build :ecwid_line_item, product: product, quantity: 2 }
    let(:product)   { build :ecwid_product, price: 10, bulk_discounts: [bulk] }
    let(:bulk)      { build :ecwid_bulk_discount, quantity: 2, price: 8 }
    let(:coupon)    { build :ecwid_coupon, type: :percent, value: 10 }
    let(:automatic) { build :ecwid_auto_discount, type: :percent, value: 10 }

    it "shouldn't shit the bed", :aggregate_failures do
      expect(order.total).to eq(12.96)
      expect(order.subtotal).to eq(16)
      expect(order.coupon_discount).to eq(1.6)
      expect(order.volume_discount).to eq(1.44)
      expect(order.discount).to eq(1.44)
      expect(order.params).to include(
        total: 12.96,
        subtotal: 16,
        couponDiscount: 1.6,
        volumeDiscount: 1.44,
        discount: 1.44
      )
    end
  end

  describe 'bulk, coupon, and voulume discount, with mutliple taxes' do
    let(:order)     { build :ecwid_order, items: [line_item], coupon: coupon, automatic_discount: automatic }
    let(:line_item) { build :ecwid_line_item, product: product, quantity: 2, taxes: [tax1, tax2] }
    let(:tax1)      { build :ecwid_tax, value: 8.75 }
    let(:tax2)      { build :ecwid_tax, value: 1.5 }
    let(:product)   { build :ecwid_product, price: 10, bulk_discounts: [bulk] }
    let(:bulk)      { build :ecwid_bulk_discount, quantity: 2, price: 8 }
    let(:coupon)    { build :ecwid_coupon, type: :percent, value: 15 }
    let(:automatic) { build :ecwid_auto_discount, type: :percent, value: 10 }

    it "shouldn't shit the bed", :aggregate_failures do
      expect(order.total).to eq(13.49)
      expect(order.subtotal).to eq(16)
      expect(order.coupon_discount).to eq(2.4)
      expect(order.volume_discount).to eq(1.36)
      expect(order.discount).to eq(1.36)
      expect(order.tax).to eq(1.25)
      expect(order.params).to include(
        total: 13.49,
        subtotal: 16,
        couponDiscount: 2.4,
        volumeDiscount: 1.36,
        discount: 1.36,
        tax: 1.25
      )
    end
  end

  describe 'bulk, coupon, and voulume discount, with mutliple taxes' do
    let(:order)     { build :ecwid_order, items: [line_item], automatic_discount: automatic, shipping_option: shipping }
    let(:line_item) { build :ecwid_line_item, product: product, quantity: 2, taxes: [tax1, tax2] }
    let(:tax1)      { build :ecwid_tax, value: 8.75, include_shipping: true }
    let(:tax2)      { build :ecwid_tax, value: 1.5, include_shipping: true  }
    let(:product)   { build :ecwid_product, price: 10, bulk_discounts: [bulk] }
    let(:bulk)      { build :ecwid_bulk_discount, quantity: 2, price: 8 }
    let(:automatic) { build :ecwid_auto_discount, type: :percent, value: 10 }
    let(:shipping)  { build :ecwid_shipping, rate: 10 }

    it "shouldn't shit the bed", :aggregate_failures do
      expect(order.total).to eq(26.91)
      expect(order.subtotal).to eq(16)
      expect(order.tax).to eq(2.51)
      expect(order.volume_discount).to eq(1.6)
      expect(order.taxes_on_shipping).to match_array(
        [
          {
            name: tax1.name,
            value: 8.75,
            total: 0.88
          },
          {
            name: tax2.name,
            value: 1.5,
            total: 0.15
          }
        ]
      )
    end
  end
end
