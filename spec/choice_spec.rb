# frozen_string_literal: true

RSpec.describe Ecwid::Choice do
  let(:choice) { build :ecwid_choice, text: text, value: value, type: type }
  let(:text)   { "Sofie's" }
  let(:value)  { 15 }
  let(:type)   { 'PERCENT' }

  describe '#to_h' do
    it 'should return valid hash' do
      expect(choice.to_h).to eq(
        text: text,
        priceModifier: value,
        priceModifierType: type
      )
    end
  end
end
