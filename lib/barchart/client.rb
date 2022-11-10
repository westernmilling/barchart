# frozen_string_literal: true

require 'barchart'
require 'httparty'
require 'active_support/core_ext'

module Barchart
  class Client # :nodoc:
    module ResponseHandlers
      class BaseHandler # :nodoc:
        def initialize(httparty)
          @httparty = httparty
        end
      end

      class HandleBadRequest < BaseHandler # :nodoc:
        def call
          fail BadRequest.new(@httparty.body, @httparty.parsed_response) \
            if @httparty.code == 400
        end
      end

      class HandleUnauthorized < BaseHandler # :nodoc:
        def call
          fail Unauthorized, @httparty.body \
            if [401, 403].include?(@httparty.code)
        end
      end
    end

    class << self
      attr_accessor :api_key,
                    :base_url,
                    :default_price_conversion_class_name,
                    :logger,
                    :price_conversion_class_names,
                    :proxy_url,
                    :request_type

      # ```ruby
      # Barchart::Client.configure do |config|
      #   config.base_url = 'http://localhost:3000'
      #   config.logger = Logger.new(STDOUT)
      #   config.api_key = 'xxx'
      #   config.price_conversion_class_names = {
      #     ZC: 'DivideBy100Price'
      #     ZM: 'OriginalPrice'
      #   }
      # end
      # ```
      # elsewhere
      #
      # ```ruby
      # client = EODBarchartData::Client.new
      # ```
      def configure
        yield self
        true
      end
    end

    attr_reader :logger

    def initialize(options = {})
      options = default_options.merge(options)

      @base_url = options[:base_url]
      @logger = options.compact.fetch(:logger, Logger.new(STDOUT))
      @proxy_url = options[:proxy_url]
      @api_key = options[:api_key]
    end

    ##
    # Futures Options
    # The futures_options method provides options on futures contracts.
    #
    # @param  [Hash]  barchart API input parameters.
    # @return [Array]
    def futures_options(params)
      params = params.merge(apikey: @api_key)

      get('getFuturesOptions', default_headers, params)
        .map do |result|
          FuturesOption.new(result)
        end
    end

    ##
    # Futures Prices
    # The futures_prices method provides access to the getQuote API call.
    #
    # @param  [Hash]  barchart API input parameters.
    # @return [Array]
    def futures_prices(params)
      params = params.merge(apikey: @api_key)

      get('getQuote', default_headers, params)
        .map do |result|
          FuturesPrice.new(result)
        end
    end

    ##
    # Futures Options
    # The special_options method provides special options on futures contracts.
    #
    # @param  [Hash]  barchart API input parameters.
    # @return [Array]
    def special_options(params)
      params = params.merge(apikey: @api_key)

      get('getSpecialOptions', default_headers, params)
        .map do |result|
          SpecialOption.new(result)
        end
    end

    protected

    ##
    # Default headers
    # A {Hash} of default headers.
    #
    # @return [Hash] containing the default headers
    def default_headers
      {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Host' => uri.host,
        'User-Agent' => 'barchart.rb'
      }
    end

    ##
    # Default options
    # A {Hash} of default options populate by attributes set during
    # configuration.
    #
    # @return [Hash] containing the default options
    def default_options
      {
        api_key: Barchart::Client.api_key,
        base_url: Barchart::Client.base_url,
        logger: Barchart::Client.logger,
        proxy_url: Barchart::Client.proxy_url
      }
    end

    def get(resource, headers = {}, params = {})
      url = "#{@base_url.chomp('/')}/#{resource}.json"

      @logger.debug("GET request Url: #{url}")
      @logger.debug("-- Headers: #{headers}")
      @logger.debug("-- Params: #{params}")

      response = raises_unless_success do
        HTTParty.get(url, headers: headers, query: params)
      end

      parse_response(response)
    end

    def parse_response(response)
      response
        .parsed_response
        .fetch('results')
        .map do |result|
          result
            .transform_keys { |key| transform_key(key) }
            .symbolize_keys
        end
    end

    def raises_unless_success
      httparty = yield

      [
        ResponseHandlers::HandleBadRequest,
        ResponseHandlers::HandleUnauthorized
      ].each do |handler_type|
        handler_type.new(httparty).call
      end

      httparty
    end

    def transform_key(key)
      # Transform price keys because open is a reserved word.
      key += 'Price' if %w[high last low open].include?(key)

      key.underscore
    end

    def uri
      @uri ||= URI.parse(@base_url)
    end

    class OriginalPrice # :nodoc:
      def initialize(price)
        @price = price
      end

      def call
        @price
      end
    end

    class DivideBy100Price # :nodoc:
      def initialize(price)
        @price = price
      end

      def call
        @price.to_f / 100
      end
    end
  end
end
