# frozen_string_literal: true

require 'spec_helper'
require 'barchart'
require 'barchart/client'

RSpec.describe Barchart::FuturesPrice do
  describe '.adjusted_last_price' do
    context 'when there is no price conversion class for the symbol' do
      it 'uses the default price conversion class' do
        # Arrange
        Barchart::Client.configure do |config|
          config.default_price_conversion_class_name = 'OriginalPrice'
          config.price_conversion_class_names = {
            ZC: 'DivideBy100Price'
          }
        end
        instance = described_class.new(last_price: 100, symbol: 'ZMZ22')
        # Act
        result = instance.adjusted_last_price
        # Assert
        expect(result).to eq(instance.last_price)
      end
    end

    context 'when there is a price conversion class for the symbol' do
      it 'uses the mapped price conversion class' do
        # Arrange
        Barchart::Client.configure do |config|
          config.default_price_conversion_class_name = 'OriginalPrice'
          config.price_conversion_class_names = {
            ZC: 'DivideBy100Price'
          }
        end
        instance = described_class.new(last_price: 100, symbol: 'ZCZ22')
        # Act
        result = instance.adjusted_last_price
        # Assert
        expect(result).to eq(instance.last_price / 100)
      end
    end
  end
end
