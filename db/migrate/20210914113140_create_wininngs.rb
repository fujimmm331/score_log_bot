class CreateWininngs < ActiveRecord::Migration[6.0]
  def change
    create_table :wininngs do |t|
      t.integer :country, null: false, limit: 1, default: 0
      t.integer :count,   null: false, limit: 1, default: 0
      t.timestamps
    end

    add_index :wininngs, :country, unique: true
  end
end
