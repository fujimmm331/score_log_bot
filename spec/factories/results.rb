FactoryBot.define do
  factory :result do
    winner { 0 }
    loser { 1 }
    association :score
  end
end
