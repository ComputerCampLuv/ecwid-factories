# frozen_string_literal: true

RSpec.describe Ecwid::Option do
  describe 'new' do
    it 'should raise an error when setting an invalid type' do
      expect { subject.type = 'INVALID' }.to raise_error(TypeError)
    end
  end

  describe '#to_h' do
    context 'when option has a default choice' do
      let(:option) { build :ecwid_option, :drop_down }

      it 'should return valid hash' do
        expect(option.to_h).to eq(
          type: 'SELECT',
          name: option.name,
          choices: option.choices.map(&:to_h),
          defaultChoice: option.default_choice,
          required: option.required
        )
      end
    end

    context 'when option has no default choice' do
      let(:option) { build :ecwid_option, :checkbox }

      it 'should return valid hash with default choice ommited' do
        expect(option.to_h).to eq(
          type: 'CHECKBOX',
          name: option.name,
          choices: option.choices.map(&:to_h),
          required: option.required
        )
      end
    end

    context 'when option has no choices' do
      let(:option) { build :ecwid_option, :text_field }

      it 'should return valid hash with default choice ommited' do
        expect(option.to_h).to eq(
          type: 'TEXTFIELD',
          name: option.name,
          required: option.required
        )
      end
    end
  end
end
