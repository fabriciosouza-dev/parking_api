require 'factory_bot'
require 'faker'
require 'bson'
require_relative '../app/models/parking'

FactoryBot.define do
  factory :parking do
    id { BSON::ObjectId.new }
    plate { "#{('A'..'Z').to_a.sample(3).join}-#{Faker::Number.number(digits: 4)}" }
    entry_time { Time.now - rand(1..120) * 60 }
    exit_time { nil }
    paid { false }
    left { false }

    initialize_with { new(plate, { '_id' => id, 'entry_time' => entry_time, 'paid' => paid, 'left' => left, 'exit_time' => exit_time }) }

    trait :paid do
      paid { true }
    end

    trait :left do
      paid { true }
      left { true }
      exit_time { Time.now }
    end
  end
end
