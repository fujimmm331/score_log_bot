FactoryBot.define do
  factory :result do
    winner { Country::FRANCE }
    loser { Country::GERMANY }
    association :score
  end
end
