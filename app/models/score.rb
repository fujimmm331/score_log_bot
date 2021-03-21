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

    if score.save 
      text = ''
      text << if (scores[0] + scores[2] > scores[1] + scores[3]) 
                '🎉㊗️フランスの勝ち！㊗️🎉' + "\n" + 'ドイツは出直してきな！😇' + "\n"
              else 
                '🎉㊗️ドイツの勝ち！㊗️🎉' + "\n" + 'フランスは出直してきな！😇' + "\n"
              end

      text << "\n"
      text << '【総試合数】' + "\n"
      text << Score.count.to_s + '試合' + "\n"

      text << "\n"
      text << '【勝ち数】' + "\n"
      text << 'フランス：' + Score.where("franse_score + pk_franse_score > germany_score + pk_germany_score").count.to_s + '勝' + "\n"
      text << 'ドイツ　：' + Score.where("franse_score + pk_franse_score < germany_score + pk_germany_score").count.to_s + '勝' + "\n"

      text << "\n"
      text << '【得点率】' + "\n"
      text << 'フランス：' + ' ' + Score.average(:franse_score).round(1).to_s + '点' + "\n"
      text << 'ドイツ　：' + ' ' + Score.average(:germany_score).round(1).to_s + '点' + "\n"

    else
      '失敗。。スコアは半角数字、半角スペースで送ってね！'
    end
  end

  def self.for_the_last_5games
    text = ''
    text << '【総試合数】' + "\n"
    text << Score.count.to_s + '試合' + "\n"

    text << "\n"
    text << '【直近５試合の結果】' + "\n"
    scores = Score.all.order(id: 'DESC').limit(5)
    scores.each do |score|
      text << score[:franse_score].to_s + ' ' + '-' + ' ' + score[:germany_score].to_s
      text <<'（' + ' ' + score[:pk_franse_score].to_s + ' ' + '-' + ' ' + score[:pk_germany_score].to_s + ' ' + '）' unless (score[:pk_franse_score] == 0 && score[:pk_germany_score] == 0)
      text << "\n"
    end

    text << "\n"
    text << '【勝ち数】' + "\n"
    text << 'フランス：' + Score.where("franse_score + pk_franse_score > germany_score + pk_germany_score").count.to_s + '勝' + "\n"
    text << 'ドイツ　：' + Score.where("franse_score + pk_franse_score < germany_score + pk_germany_score").count.to_s + '勝' + "\n"

    text << "\n"
    text << '【得点率】' + "\n"
    text << 'フランス：' + ' ' + Score.average(:franse_score).round(1).to_s + '点' + "\n"
    text << 'ドイツ　：' + ' ' + Score.average(:germany_score).round(1).to_s + '点' + "\n"

    return text
  end
end


# select count(*) AS "総試合数",sum(case when franse_score + pk_franse_score > germany_score + pk_germany_score then 1 else 0 end) AS "フランスの勝ち数",sum(case when franse_score + pk_franse_score < germany_score + pk_germany_score then 1 else 0 end) AS "ドイツの勝ち数"from scores;