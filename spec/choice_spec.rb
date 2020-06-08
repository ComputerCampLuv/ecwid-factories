# frozen_string_literal: true

RSpec.describe Ecwid::Choice do
  describe '#new' do
    it 'should initialize with a single argument' do
      expect(Ecwid::Choice.new('text description')).to be_an(Ecwid::Choice)
    end

    it 'should raise an error when setting an invalid type' do
      expect { Ecwid::Choice.new('text', 1, 'INVALID') }.to raise_error(TypeError)
    end
  end

  describe '#type=' do
    let(:choice) { build :ecwid_choice, type: 'ABSOLUTE' }

    it 'should update the choices type' do
      choice.type = 'PERCENT'

      expect(choice.type).to eq('PERCENT')
    end

    it 'should not set an invalid type and instead raise a TypeError', :aggregate_failures do
      expect { choice.type = 'INVALID' }.to raise_error(TypeError)
      expect(choice.type).not_to eq('INVALID')
    end
  end

  describe '#to_h' do
    let(:choice) { build :ecwid_choice, text: text, value: value, type: type }
    let(:text)   { "Sofie's" }
    let(:value)  { 15 }
    let(:type)   { 'PERCENT' }

    it 'should return valid hash' do
      expect(choice.to_h).to eq(
        text: text,
        priceModifier: value,
        priceModifierType: type
      )
    end
  end
end
