# frozen_string_literal: true

RSpec.describe Ecwid::Variant do
  let(:variant) { Ecwid::Variant.new(product: product, options: options) }
  let(:options) { [{ name: option.name, value: choice.text }] }
  let(:product) { build :ecwid_product, options: [option] }
  let(:option)  { build :ecwid_option, choices: [choice] }
  let(:choice)  { build :ecwid_choice }

  describe '#params' do
    it 'should return valid params' do
      expect(variant.params).to eq(options: options)
    end
  end
end
