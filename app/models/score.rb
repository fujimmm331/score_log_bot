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

  def self.total_wins
    return "\n" + '【勝ち数】' + "\n" + 'フランス：' + Score.where("franse_score + pk_franse_score > germany_score + pk_germany_score").count.to_s + '勝' + "\n" + 'ドイツ　：' + Score.where("franse_score + pk_franse_score < germany_score + pk_germany_score").count.to_s + '勝' + "\n"
  end

  def self.scoring_rate
    return "\n" + '【得点率】' + "\n" + 'フランス：' + ' ' + Score.average(:franse_score).round(1).to_s + '点' + "\n" + 'ドイツ　：' + ' ' + Score.average(:germany_score).round(1).to_s + '点' + "\n"
  end

  def self.total_scores
    total_flance_score = Score.sum(:franse_score)
    total_germany_score = Score.sum(:germany_score)
    return  "\n" + '【得点】' + "\n" + 'フランス：' + ' ' + total_flance_score.to_s + '点' + "\n" + 'ドイツ　：' + ' ' + total_germany_score.to_s + '点' + "\n" + '合計　　：' + ' ' + (total_flance_score + total_germany_score).to_s + '点' + "\n"
  end

  def self.total_matches
    return '【総試合数】' + "\n" +  Score.count.to_s + '試合' + "\n"
  end

  def self.saved_from_message(params)
    scores = params.split(" ").map!(&:to_i)
    score = Score.new(franse_score: scores[0], germany_score: scores[1], pk_franse_score: scores[2], pk_germany_score: scores[3])

    if score.save 
      text = ''
      text << if (scores[0] + scores[2] > scores[1] + scores[3]) 
                '🎉㊗️フランスの勝ち㊗️🎉' + "\n" + 'ドイツは出直してきな🖕😇🖕' + "\n" + "\n"
              else
                '🎉㊗️ドイツの勝ち㊗️🎉' + "\n" + 'フランスは出直してきな🖕😇🖕' + "\n" + "\n"
              end

      text << Score.total_matches
      text << Score.total_wins
      text << Score.scoring_rate
      text << Score.total_scores

    else
      '失敗。。スコアは半角数字、半角スペースで送ってね！'
    end
  end

  def self.result
    text = ''
    text << Score.total_matches

    text << "\n"
    text << '【直近５試合の結果】' + "\n"
    scores = Score.all.order(id: 'DESC').limit(5)
    scores.each do |score|
      text << score[:franse_score].to_s + ' ' + '-' + ' ' + score[:germany_score].to_s
      text <<'（' + ' ' + score[:pk_franse_score].to_s + ' ' + '-' + ' ' + score[:pk_germany_score].to_s + ' ' + '）' unless (score[:pk_franse_score] == 0 && score[:pk_germany_score] == 0)
      text << "\n"
    end

    text << Score.total_wins
    text << Score.scoring_rate
    text << Score.total_scores
  end
end
