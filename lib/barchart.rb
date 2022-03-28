# frozen_string_literal: true

module Barchart
  MONTH_CODE_MAP = {
    'F' => 1,
    'G' => 2,
    'H' => 3,
    'J' => 4,
    'K' => 5,
    'M' => 6,
    'N' => 7,
    'Q' => 8,
    'U' => 9,
    'V' => 10,
    'X' => 11,
    'Z' => 12
  }.freeze

  # Errors
  class BaseError < StandardError # :nodoc:
    attr_reader :response

    def initialize(message = nil, response = nil)
      super(message)

      @response = response
    end
  end
  class BadRequest < BaseError; end
  class Unauthorized < BaseError; end

  # Resources
  class FuturesOption < OpenStruct
    def options_type
      :american
    end

    def adjusted_price
      price = send(__callee__.to_s.sub('adjusted_', '').to_sym)

      convert_price(price)
    end

    alias adjusted_last_price adjusted_price

    protected

    def convert_price(price)
      symbol_symbol = contract[0, 2].to_sym
      converter_klass = Object.const_get(
        [
          'Barchart::Client',
          Barchart::Client.price_conversion_class_names[symbol_symbol]
        ].join('::')
      )

      converter_klass.new(price).call
    end
  end

  class FuturesPrice < OpenStruct # :nodoc:
    def adjusted_price
      price = send(__callee__.to_s.sub('adjusted_', '').to_sym)

      convert_price(price)
    end

    alias adjusted_last_price adjusted_price

    protected

    def convert_price(price)
      symbol_symbol = symbol[0, 2].to_sym
      converter_klass = Object.const_get(
        [
          'Barchart::Client',
          Barchart::Client.price_conversion_class_names[symbol_symbol]
        ].join('::')
      )

      converter_klass.new(price).call
    end
  end

  class SpecialOption < OpenStruct; end
end
