class RenameFranseScoreColumnToScores < ActiveRecord::Migration[6.0]
  def change
    rename_column :scores, :franse_score, :france
    rename_column :scores, :germany_score, :germany
    rename_column :scores, :pk_franse_score, :france_pk
    rename_column :scores, :pk_germany_score, :germany_pk
  end
end
