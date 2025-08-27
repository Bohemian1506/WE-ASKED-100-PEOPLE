require 'rails_helper'

RSpec.describe ApplicationRecord, type: :model do
  describe 'Rails application' do
    it 'loads successfully' do
      expect(Rails.application).to be_present
    end
  end

  describe 'database connection' do
    it 'establishes connection' do
      expect(ActiveRecord::Base.connection).to be_active
    end
  end
end