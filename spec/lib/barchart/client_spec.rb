# frozen_string_literal: true

require 'spec_helper'
require 'barchart/client'

RSpec.describe Barchart::Client do
  describe '.configure' do
    it 'sets configuration attributes' do
      # Arrange
      api_key = SecureRandom.uuid
      base_url = 'http://localhost:8080'
      # Act
      Barchart::Client.configure do |config|
        config.api_key = api_key
        config.base_url = base_url
      end
      # Assert
      expect(Barchart::Client).to have_attributes(
        api_key: api_key,
        base_url: base_url
      )
    end
  end

  describe '#futures_options' do
    context 'when no api key is provided' do
      it 'fails with a 401' do
        # Arrange
        api_key = ''
        base_url = 'http://localhost:8080'
        client = described_class.new(
          api_key: api_key,
          base_url: base_url,
          logger: Logger.new(IO::NULL)
        )
        uri = URI.parse(base_url)

        params = {
          apikey: api_key,
          root: 'ZC'
        }
        response = {
          body: 'API key is missing or not valid.',
          headers: {
            'Accept' => 'text/html',
            'Content-Type' => 'text/html'
          },
          status: 401
        }
        stub_request(
          :get,
          "#{base_url}/getFuturesOptions.json?#{params.to_query}"
        )
          .with(
            headers: {
              'Accept' => 'application/json',
              'Content-Type' => 'application/json',
              'Host' => uri.host,
              'User-Agent' => 'barchart.rb'
            }
          )
          .to_return(response)
        # Act and Assert
        expect { client.futures_options(root: 'ZC') }
          .to raise_error(
            Barchart::Unauthorized, 'API key is missing or not valid.'
          )
      end
    end

    context 'when no filter is provided' do
      it 'fails with a 400' do
        # Arrange
        api_key = SecureRandom.uuid
        base_url = 'http://localhost:8080'
        client = described_class.new(
          api_key: api_key,
          base_url: base_url,
          logger: Logger.new(IO::NULL)
        )
        uri = URI.parse(base_url)

        params = {
          apikey: api_key
        }
        response = {
          body: 'Input: exchange, root, contract or symbols is required.',
          headers: {
            'Accept' => 'text/html',
            'Content-Type' => 'text/html'
          },
          status: 400
        }
        stub_request(
          :get,
          "#{base_url}/getFuturesOptions.json?#{params.to_query}"
        )
          .with(
            headers: {
              'Accept' => 'application/json',
              'Content-Type' => 'application/json',
              'Host' => uri.host,
              'User-Agent' => 'barchart.rb'
            }
          )
          .to_return(response)
        # Act and Assert
        expect { client.futures_options({}) }
          .to raise_error(
            Barchart::BadRequest,
            'Input: exchange, root, contract or symbols is required.'
          )
      end
    end

    context 'when a contract filter is provided' do
      it 'returns futures options' do
        # Arrange
        api_key = SecureRandom.uuid
        base_url = 'http://localhost:8080'
        client = described_class.new(
          api_key: api_key,
          base_url: base_url,
          logger: Logger.new(IO::NULL)
        )
        uri = URI.parse(base_url)

        futures_options_data = build_list(:futures_option, 2)

        params = {
          apikey: api_key,
          contract: 'ZCK20'
        }
        response = {
          body: {
            status: {
              code: 200,
              message: 'Success.'
            },
            results: futures_options_data
          }.to_json,
          headers: {
            'Accept' => 'application/json',
            'Content-Type' => 'application/json'
          },
          status: 200
        }
        stub_request(
          :get,
          "#{base_url}/getFuturesOptions.json?#{params.to_query}"
        )
          .with(
            headers: {
              'Accept' => 'application/json',
              'Content-Type' => 'application/json',
              'Host' => uri.host,
              'User-Agent' => 'barchart.rb'
            }
          )
          .to_return(response)
        # Act
        result = client.futures_options(params.slice(:contract))
        # Assert
        expect(result).to contain_exactly(
          *(
            futures_options_data.map do |data|
              have_attributes(
                contract: data['contract'],
                contract_month: data['contractMonth'],
                contract_name: data['contractName'],
                date: data['date'],
                delta: data['delta'],
                exchange: data['exchange'],
                expiration_date: data['expirationDate'],
                gamma: data['gamma'],
                high_price: data['high'],
                implied_volatility: data['impliedVolatility'],
                last_price: data['last'],
                low_price: data['low'],
                open_price: data['open'],
                percent_change: data['percentChange'],
                previous_close: data['previousClose'],
                root: data['root'],
                strike: data['strike'],
                symbol: data['symbol'],
                type: data['type'],
                theta: data['theta'],
                vega: data['vega'],
                volume: data['volume']
              )
            end
          )
        )
      end
    end
  end

  # TODO: Add test for #futures_prices

  describe '#special_options' do
    context 'when a contract filter is provided' do
      it 'returns special options' do
        # Arrange
        api_key = SecureRandom.uuid
        base_url = 'http://localhost:8080'
        client = described_class.new(
          api_key: api_key,
          base_url: base_url,
          logger: Logger.new(IO::NULL)
        )
        uri = URI.parse(base_url)

        special_options_data = build_list(:special_option, 2)

        params = {
          apikey: api_key,
          contract: 'ZCK20',
          fields: 'last'
        }
        response = {
          body: {
            status: {
              code: 200,
              message: 'Success.'
            },
            results: special_options_data
          }.to_json,
          headers: {
            'Accept' => 'application/json',
            'Content-Type' => 'application/json'
          },
          status: 200
        }
        stub_request(
          :get,
          "#{base_url}/getSpecialOptions.json?#{params.to_query}"
        )
          .with(
            headers: {
              'Accept' => 'application/json',
              'Content-Type' => 'application/json',
              'Host' => uri.host,
              'User-Agent' => 'barchart.rb'
            }
          )
          .to_return(response)
        # Act
        result = client.special_options(params.slice(:contract, :fields))
        # Assert
        expect(result).to contain_exactly(
          *(
            special_options_data.map do |data|
              have_attributes(
                contract: data['contract'],
                contract_month: data['contractMonth'],
                contract_name: data['contractName'],
                date: data['date'],
                exchange: data['exchange'],
                expiration_date: data['expirationDate'],
                last_price: data['last'],
                root: data['root'],
                strike: data['strike'],
                symbol: data['symbol'],
                type: data['type']
              )
            end
          )
        )
      end
    end
  end
end
