class Result < ApplicationRecord
  belongs_to :score

  bind_inum :winner, Country, _prefix: true
  bind_inum :loser,  Country, _prefix: true

  with_options presence: true do
    validates :winner
    validates :loser
    validates :score_id
  end
end
