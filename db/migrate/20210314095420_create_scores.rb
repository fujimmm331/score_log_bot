class CreateScores < ActiveRecord::Migration[6.0]
  def change
    create_table :scores do |t|
      t.integer :franse_score,     null: false
      t.integer :germany_score,    null: false
      t.integer :pk_franse_score,  null: false
      t.integer :pk_germany_score, null: false
      t.timestamps
    end
  end
end
