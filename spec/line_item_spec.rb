# frozen_string_literal: true

RSpec.describe Ecwid::LineItem do
  let(:product) { build :ecwid_product, price: 10 }

  before do
    allow(product).to receive(:sku).and_return('101')
    allow(product).to receive(:discounts_allowed).and_return(true)
    allow(product).to receive(:is_gift_card).and_return(false)
    allow(product).to receive(:tax).and_return(taxable: true)
  end

  describe 'crazy' do
    let(:line_item)  { build :ecwid_line_item, product: product, quantity: 2, selections: selections }
    let(:product)    { build :ecwid_product, price: 10, id: 1, options: [option1, option2], bulk_discounts: [discount] }
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

    it 'should return hash populated with the correct data' do
      expect(line_item.to_h).to include(
        productId: 1,
        name: product.name,
        price: 10.7,
        productPrice: 10,
        sku: '101',
        discountsAllowed: true,
        isGiftCard: false,
        taxable: true,
        quantity: 2,
        tax: 0,
        taxes: [],
        selectedOptions: [
          {
            name: option1.name,
            value: choice1.text,
            type: 'RADIO',
            selections: [
              {
                selectionTitle: choice1.text,
                selectionModifier: 13,
                selectionModifierType: 'PERCENT'
              }
            ]
          },
          {
            name: option2.name,
            value: "#{choice2.text}, #{choice3.text}",
            valuesArray: [choice2.text, choice3.text],
            type: 'CHECKBOX',
            selections: [
              {
                selectionTitle: choice2.text,
                selectionModifier: -5.5,
                selectionModifierType: 'PERCENT'
              },
              {
                selectionTitle: choice3.text,
                selectionModifier: 2.1,
                selectionModifierType: 'ABSOLUTE'
              }
            ]
          }
        ]
      )
    end
  end

  describe '#subtotal' do
    context 'when the line item has a quantity of 1 and no tax' do
      let(:line_item) { build :ecwid_line_item, product: product }

      it 'should return the correct subtotal' do
        expect(line_item.subtotal).to eq(10)
      end
    end

    context 'when the line item has a quantity of 2 and no tax' do
      let(:line_item) { build :ecwid_line_item, product: product, quantity: 2 }

      it 'should return the correct subtotal' do
        expect(line_item.subtotal).to eq(20)
      end
    end

    context 'when the line item has a quantity of 1 and includes a single tax' do
      let(:line_item) { build :ecwid_line_item, product: product, taxes: [tax] }
      let(:tax)       { build :ecwid_tax }

      it "should return the correct subtotal that doesn't include tax" do
        expect(line_item.subtotal).to eq(10)
      end
    end

    context 'when the product has a bulk discount' do
      let(:product)   { build :ecwid_product, price: 10, bulk_discounts: [discount] }
      let(:discount)  { build :ecwid_bulk_discount, quantity: 2, price: 7.5 }

      context 'when the line item has a quantity of 2 and qualifies for a bulk discount' do
        let(:line_item) { build :ecwid_line_item, product: product, quantity: 2 }

        it 'should return the correct subtotal that includes the bulk discount' do
          expect(line_item.subtotal).to eq(15)
        end
      end

      context "when the line item quantity doesn't qualify for a bulk discount" do
        let(:line_item) { build :ecwid_line_item, product: product, quantity: 1 }

        it 'should return the correct subtotal that excludes the bulk discount' do
          expect(line_item.subtotal).to eq(10)
        end
      end
    end
  end

  describe '#total' do
    context 'when the line item has a quantity of 1 and no tax' do
      let(:line_item) { build :ecwid_line_item, product: product }

      it 'should return the correct total' do
        expect(line_item.total).to eq(10)
      end
    end

    context 'when the line item has a quantity of 2 and no tax' do
      let(:line_item) { build :ecwid_line_item, product: product, quantity: 2 }

      it 'should return the correct total' do
        expect(line_item.total).to eq(20)
      end
    end

    context 'when the line item has a quantity of 1 and includes a single tax' do
      let(:line_item) { build :ecwid_line_item, product: product, taxes: [tax] }
      let(:tax)       { build :ecwid_tax, value: 15 }

      it 'should return the correct total including tax' do
        expect(line_item.total).to eq(11.5)
      end
    end

    context 'when the line item has a quantity of 2 and includes a single tax' do
      let(:line_item) { build :ecwid_line_item, product: product, quantity: 2, taxes: [tax] }
      let(:tax)       { build :ecwid_tax, value: 15 }

      it 'should return the correct total including tax' do
        expect(line_item.total).to eq(23)
      end
    end

    context 'when the product has a bulk discount' do
      let(:product)  { build :ecwid_product, price: 10, bulk_discounts: [discount] }
      let(:discount) { build :ecwid_bulk_discount, quantity: 2, price: 7.5 }
      let(:tax)      { build :ecwid_tax, value: 10 }

      context 'when the line item has a quantity of 2 and qualifies for a bulk discount' do
        let(:line_item) { build :ecwid_line_item, product: product, quantity: 2, taxes: [tax] }

        it 'should return the correct total with tax applied to the discounted price' do
          expect(line_item.total).to eq(16.5)
        end
      end

      context "when the line item quantity doesn't qualify for a bulk discount" do
        let(:line_item) { build :ecwid_line_item, product: product, quantity: 1, taxes: [tax] }

        it 'should return the correct total with tax applied to the full price' do
          expect(line_item.total).to eq(11)
        end
      end
    end
  end

  describe '#tax_total' do
    context 'when no tax is applied' do
      let(:line_item) { build :ecwid_line_item, product: product }

      it 'should be zero' do
        expect(line_item.tax_total).to be_zero
      end
    end

    context 'when tax is applied' do
      let(:line_item) { build :ecwid_line_item, product: product, taxes: [tax] }
      let(:tax)       { build :ecwid_tax, value: 12 }

      it 'should return the correct tax amount' do
        expect(line_item.tax_total).to eq(1.2)
      end
    end

    context 'when tax is applied on multiple items' do
      let(:line_item) { build :ecwid_line_item, product: product, quantity: 100, taxes: [tax] }
      let(:product)   { build :ecwid_product, price: 1 }
      let(:tax)       { build :ecwid_tax, value: 0.5 }

      it 'should calculate the tax on the combined price of all items' do
        expect(line_item.tax_total).to eq(0.5)
      end
    end

    context 'when the product has a bulk discount' do
      let(:product)  { build :ecwid_product, price: 10, bulk_discounts: [discount] }
      let(:discount) { build :ecwid_bulk_discount, quantity: 2, price: 7.5 }
      let(:tax)      { build :ecwid_tax, value: 17.5 }

      context 'when the line item has a quantity of 2 and qualifies for a bulk discount' do
        let(:line_item) { build :ecwid_line_item, product: product, quantity: 2, taxes: [tax] }

        it 'should return the correct tax total with tax applied to the discounted price' do
          expect(line_item.tax_total).to eq(2.63)
        end
      end

      context "when the line item quantity doesn't qualify for a bulk discount" do
        let(:line_item) { build :ecwid_line_item, product: product, quantity: 1, taxes: [tax] }

        it 'should return the correct tax total with tax applied to the full price' do
          expect(line_item.tax_total).to eq(1.75)
        end
      end
    end
  end

  describe '#tax_params' do
    context 'when a single tax is applied to the line item' do
      let(:line_item) { build :ecwid_line_item, product: product, taxes: [tax] }
      let(:tax)       { build :ecwid_tax }

      it 'should return an array with a single set of tax params' do
        tax_params = tax.calculate_for(product.price)

        expect(line_item.taxes.map(&:to_h)).to eq([tax_params])
      end
    end

    context 'when multiple taxes are applied to the line item' do
      let(:line_item) { build :ecwid_line_item, product: product, taxes: taxes }
      let(:taxes)     { build_list(:ecwid_tax, 3) }

      it 'should return an array of multiple tax params' do
        taxes_params = taxes.map { |tax| tax.calculate_for(product.price) }

        expect(line_item.taxes.map(&:to_h)).to eq(taxes_params)
      end
    end
  end

  describe '#to_h' do
    let(:product)  { build :ecwid_product, id: 1, price: 10, bulk_discounts: [discount] }
    let(:discount) { build :ecwid_bulk_discount, quantity: 3, price: 8 }

    before do
      allow(product).to receive(:data).and_return(
        defaultCategoryId: 0,
        sku: '101',
        discountsAllowed: true,
        isGiftCard: false,
        tax: { taxable: true }
      )
    end

    context 'when the line item has a quantity of 1, with no tax and no discount applied' do
      let(:line_item) { build :ecwid_line_item, product: product }

      it 'should return hash populated with the correct data' do
        expect(line_item.to_h).to include(
          productId: 1,
          name: product.name,
          price: 10,
          productPrice: 10,
          sku: '101',
          discountsAllowed: true,
          isGiftCard: false,
          taxable: true,
          quantity: 1,
          tax: 0,
          taxes: []
        )
      end
    end

    context 'when the line item qualifies for bulk discount, and does not include tax' do
      let(:line_item) { build :ecwid_line_item, product: product, quantity: 3 }

      it 'should return hash populated with the correct data' do
        expect(line_item.to_h).to include(
          productId: 1,
          name: product.name,
          price: 8,
          productPrice: 10,
          sku: '101',
          discountsAllowed: true,
          isGiftCard: false,
          taxable: true,
          quantity: 3,
          tax: 0,
          taxes: []
        )
      end
    end

    context 'when the line item qualifies for bulk discount, and includes option choices that alter the item price' do
      let(:line_item)  { build :ecwid_line_item, product: product, quantity: 2, selections: selections }
      let(:product)    { build :ecwid_product, id: 1, price: 10, bulk_discounts: [discount], options: [option] }
      let(:discount)   { build :ecwid_bulk_discount, quantity: 2, price: 8 }
      let(:option)     { build :ecwid_option, choices: [choice] }
      let(:selections) { [{ name: option.name, value: choice.text }] }

      context 'when the modifier type is for a fixed amount' do
        let(:choice) { build :ecwid_choice, value: 1.50 }

        it 'should return hash populated with the correct data' do
          expect(line_item.to_h).to include(
            productId: 1,
            price: 9.5,
            productPrice: 10,
            sku: '101',
            quantity: 2,
            name: product.name,
            selectedOptions: [
              {
                name: option.name,
                value: choice.text,
                type: option.type,
                selections: [
                  {
                    selectionTitle: choice.text,
                    selectionModifier: 1.5,
                    selectionModifierType: choice.type
                  }
                ]
              }
            ],
            discountsAllowed: true,
            isGiftCard: false,
            tax: 0,
            taxable: true,
            taxes: []
          )
        end
      end

      context 'when the modifier type is for a percentage amount' do
        let(:choice) { build :ecwid_choice, value: 10, type: 'PERCENT' }

        it 'should return hash populated with the correct data' do
          expect(line_item.to_h).to include(
            productId: 1,
            price: 8.80,
            productPrice: 10,
            sku: '101',
            quantity: 2,
            name: product.name,
            selectedOptions: [
              {
                name: option.name,
                value: choice.text,
                type: option.type,
                selections: [
                  {
                    selectionTitle: choice.text,
                    selectionModifier: 10,
                    selectionModifierType: choice.type
                  }
                ]
              }
            ],
            discountsAllowed: true,
            isGiftCard: false,
            tax: 0,
            taxable: true,
            taxes: []
          )
        end
      end
    end
  end
end
