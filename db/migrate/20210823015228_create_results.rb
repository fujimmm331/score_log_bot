class CreateResults < ActiveRecord::Migration[6.0]
  def change
    create_table :results do |t|
      t.integer :winner,   null: false, limit: 1, default: 0
      t.integer :loser,    null: false, limit: 1, default: 1
      t.references :score, foreign_key: true
      t.timestamps
    end
  end
end
