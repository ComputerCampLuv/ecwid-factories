# frozen_string_literal: true

RSpec.describe Ecwid::Customer do
  let(:first_name) { Faker::Name.first_name }
  let(:last_name)  { Faker::Name.last_name }
  let(:customer) do
    build :ecwid_customer,
          first_name: first_name,
          last_name: last_name
  end

  describe '#name' do
    it 'should combine first and last name' do
      expect(customer.name).to eq("#{first_name} #{last_name}")
    end
  end

  describe '#partial' do
    it 'should include only the name fields' do
      expect(customer.partial).to eq(
        name: customer.name,
        firstName: first_name,
        lastName: last_name
      )
    end
  end

  describe '#full' do
    it 'should include all fields' do
      expect(customer.full).to include(
        :street, :city, :countryCode, :countryName,
        :postalCode, :stateOrProvinceCode, :stateOrProvinceName
      )
    end
  end
end
