# frozen_string_literal: true

FactoryBot.define do
  factory :futures_option, class: Hash do
    skip_create

    transient do
      contract_year { Date.current.year }
    end

    sequence(:exchange) { |n| "E#{n}" }
    sequence(:root) { |n| "R#{n}" }

    contract { "#{root}#{contract_month}#{contract_year.to_s[-2, 2]}" }
    contract_month { Barchart::MONTH_CODE_MAP.keys.sample }
    contract_name { "Contract #{root}" }
    date { Date.current.strftime('%F') }
    delta { 0 }
    expiration_date { (Date.current + 1.week).strftime('%F') }
    gamma { 0 }
    high { 0 }
    implied_volatility { 0 }
    last { 0 }
    low { 0 }
    open { 0 }
    percent_change { 0 }
    previous_close { 0 }
    sequence(:strike) { |n| 100 + (n * 5) }
    symbol { "#{contract}S#{strike}#{type[0]}" }
    theta { 0 }
    type { %w[Call Put].sample }
    vega { 0 }
    volume { 0 }

    initialize_with do
      attributes
        .transform_keys { |key| key.to_s.camelize(:lower) }
    end
  end
end
