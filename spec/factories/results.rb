FactoryBot.define do
  factory :result do
    winner { Country::FLANCE }
    loser { Country::GERMANY }
    association :score
  end
end
