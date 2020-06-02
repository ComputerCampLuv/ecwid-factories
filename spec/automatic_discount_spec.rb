# frozen_string_literal: true

require 'automatic_discount'

RSpec.describe Ecwid::AutomaticDiscount do
  describe 'new' do
    it 'should raise an error when setting an invalid type' do
      expect { subject.type = 'INVALID' }.to raise_error(TypeError)
    end
  end
end
