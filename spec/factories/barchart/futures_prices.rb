# frozen_string_literal: true

FactoryBot.define do
  factory :futures_price, class: Hash do
    skip_create

    transient do
      contract_month { Barchart::MONTH_CODE_MAP.keys.sample }
      contract_year { Date.current.year }
      time_now { Time.now }

      sequence(:commodity_code) { |seq| "Z#{seq}" }
    end

    close { last_price + Faker::Commerce.price(range: -10..10) }
    day_code { time_now.day }
    dollar_volume { 0 }
    flag { '' }
    high_price { last_price + Faker::Commerce.price(range: 0..10) }
    last_price { Faker::Commerce.price }
    low_price { last_price - Faker::Commerce.price(range: 0..10) }
    mode { 'I' }
    name { Faker::Commerce.product_name }
    net_change { 0 }
    num_trades { 0 }
    open_price { last_price + Faker::Commerce.price(range: -10..10) }
    percent_change { 0 }
    previous_volume { 0 }
    server_timestamp { time_now.iso8601 }
    symbol { "#{contract_month}#{contract_year.to_s[-2, 2]}" }
    trade_timestamp { time_now.iso8601 }
    unit_code { -1 }
    volume { 0 }

    initialize_with do
      attributes
        .transform_keys { |key| key.to_s.camelize(:lower) }
    end
  end
end
