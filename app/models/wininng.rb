class Wininng < ApplicationRecord
  validates :count,   numericality: { only_integer: true }, presence: true
  validates :country, uniqueness: true
  
  with_options presence: true do
    validates :count
    validates :country
  end

  bind_inum :country, Country

  def self.update_count_of_winner_and_loser!(winner, loser)
    wininng_record_of_winner = Wininng.find_or_create_by(country: winner)
    loser_record_of_winner = Wininng.find_or_create_by(country: loser)

    wininng_record_of_winner.update!(count: wininng_record_of_winner[:count] += 1)
    loser_record_of_winner.update!(count: 0)
  end
end
