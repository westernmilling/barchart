# frozen_string_literal: true

FactoryBot.define do
  factory :special_option, class: Hash do
    skip_create

    # NB: This data doesn't really match a real response, but its close enough
    #     for the purpose of testing.
    transient do
      contract_year { Date.current.year }
      sequence(:week) { |n| n }
      symbol_prefix { ('A'...'Z').to_a.sample }
    end

    sequence(:exchange) { |n| "E#{n}" }
    sequence(:root) { |n| "R#{n}" }

    contract { "#{symbol_prefix}#{contract_month}#{contract_year.to_s[-2, 2]}" }
    contract_month { Barchart::MONTH_CODE_MAP.keys.sample }
    contract_name { "Contract #{contract}" }
    date { Date.current.strftime('%F') }
    expiration_date { (Date.current + 1.week).strftime('%F') }
    last { 0 }
    sequence(:strike) { |n| 100 + (n * 5) }
    symbol { "#{contract}|#{strike}#{type[0]}" }
    type { %w[Call Put].sample }
    underlying_future { "#{root}#{contract_month}#{contract_year.to_s[-2, 2]}" }

    initialize_with do
      attributes
        .transform_keys { |key| key.to_s.camelize(:lower) }
    end
  end
end
