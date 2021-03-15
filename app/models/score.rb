class Score < ApplicationRecord
  with_options presence: true do
    validates :franse_score
    validates :germany_score
    validates :pk_franse_score
    validates :pk_germany_score
  end
  
  with_options numericality: { only_integer: true } do
    validates :franse_score
    validates :germany_score
    validates :pk_franse_score
    validates :pk_germany_score
  end

  def self.is_saved_from_line_message(params)
    scores = params.split(" ").map!(&:to_i)
    score = Score.new(franse_score: scores[0], germany_score: scores[1], pk_franse_score: scores[2], pk_germany_score: scores[3])
    score.save ? '成功！' : '失敗。。半角数字、半角スペースで送ってね！'
  end

  def self.for_the_last_5games
    text = 'フランス - ドイツ（PK）' + "\n"
    scores = Score.all.order(id: 'DESC').limit(5)
    scores.each do |score|
      text << score[:franse_score].to_s + ' ' + '-' + ' ' + score[:germany_score].to_s
      text <<'（' + ' ' + score[:pk_franse_score].to_s + ' ' + '-' + ' ' + score[:pk_germany_score].to_s + ' ' + '）' unless (score[:pk_franse_score] == 0 && score[:pk_germany_score] == 0)
      text << "\n"
    end
    return text
  end
end
