# frozen_string_literal: true

require 'ostruct'

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
  class FuturesBase < OpenStruct # :nodoc:
    def adjusted_price
      price = send(__callee__.to_s.sub('adjusted_', '').to_sym)

      convert_price(price)
    end

    alias adjusted_last_price adjusted_price

    protected

    def convert_price(price)
      converter_klass = Object.const_get(
        ['Barchart::Client', price_conversion_class_name].join('::')
      )

      converter_klass.new(price).call
    end

    def price_conversion_class_name
      symbol_symbol = symbol[0, 2].to_sym

      Barchart::Client
        .price_conversion_class_names
        .fetch(
          symbol_symbol,
          Barchart::Client.default_price_conversion_class_name
        )
    end
  end

  class FuturesOption < FuturesBase # :nodoc:
    def options_type
      :american
    end
  end

  class FuturesPrice < FuturesBase # :nodoc:
    alias adjusted_net_change adjusted_price
  end

  class SpecialOption < OpenStruct; end
end
