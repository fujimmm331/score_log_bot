class Wininng < ApplicationRecord
  validates :count,   numericality: { only_integer: true }, presence: true
  validates :country, uniqueness: true
  
  with_options presence: true do
    validates :count
    validates :country
  end

  bind_inum :country, Country
end
