# frozen_string_literal: true

require 'coupon'

RSpec.describe Ecwid::Coupon do
  describe 'new' do
    it 'should raise an error when setting an invalid type' do
      expect { subject.type = 'INVALID' }.to raise_error(TypeError)
    end
  end
end
