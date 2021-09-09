class Result < ApplicationRecord
  belongs_to :score

  countries = {フランス: 0, ドイツ: 1}
  enum winner: countries, _prefix: true
  enum loser: countries, _prefix: true

  with_options presence: true do
    validates :winner
    validates :loser
    validates :score_id
  end
end
