class Score < ApplicationRecord
  has_one :result
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
    return '【勝ち数】' + "\n" + 'フランス：' + Score.where("franse_score + pk_franse_score > germany_score + pk_germany_score").count.to_s + '勝' + "\n" + 'ドイツ　：' + Score.where("franse_score + pk_franse_score < germany_score + pk_germany_score").count.to_s + '勝' + "\n" + "\n"
  end

  def self.scoring_rate
    return '【得点率】' + "\n" + 'フランス：' + ' ' + Score.average(:franse_score).round(1).to_s + '点' + "\n" + 'ドイツ　：' + ' ' + Score.average(:germany_score).round(1).to_s + '点' + "\n" + "\n"
  end

  def self.total_scores
    total_flance_score = Score.sum(:franse_score)
    total_germany_score = Score.sum(:germany_score)
    return '【総得点】' + "\n" + 'フランス：' + ' ' + total_flance_score.to_s + '点' + "\n" + 'ドイツ　：' + ' ' + total_germany_score.to_s + '点' + "\n" + '合計　　：' + ' ' + (total_flance_score + total_germany_score).to_s + '点' + "\n" + "\n"
  end

  def self.total_matches
    return '【総試合数】' + "\n" +  Score.count.to_s + '試合' + "\n" + "\n"
  end

  def self.is_next_match?
    next_matche = Score.count + 1
    (next_matche % 10 == 0) ? "次は記念すべき#{next_matche}試合目やでぇ！！" : "次はどっちが勝つかな？"
  end

  def self.match_result(scores, text)
    text << (scores.length == 1 ? '【得点】' : '【直近５試合の結果】')
    text << "\n"
    scores.each do |score|
      text << score[:franse_score].to_s + ' ' + '-' + ' ' + score[:germany_score].to_s
      text << '（' + ' ' + score[:pk_franse_score].to_s + ' ' + '-' + ' ' + score[:pk_germany_score].to_s + ' ' + '）' unless (score[:pk_franse_score] == 0 && score[:pk_germany_score] == 0)
      text << "\n"
    end
    text << "\n"
  end

  def self.save_from_message(scores)
    # pk戦じゃなければ0を代入する
    if scores.length == 2
      pk_flanse_score = 0
      pk_germany_score = 0
    end

    if scores.length == 4
      pk_flanse_score = scores[2]
      pk_germany_score = scores[3]
    end

    raise ArgumentError, "#{scores} is invalid length" unless scores.length == 2 || scores.length == 4

    winner = (scores[0] + pk_flanse_score > scores[1] + pk_germany_score) ? "FLANCE" : "GERMANY"
    loser = (winner == "FLANCE") ? "GERMANY" : "FLANCE"
    score = Score.new(franse_score: scores[0], germany_score: scores[1], pk_franse_score: pk_flanse_score, pk_germany_score: pk_germany_score)
    result = score.build_result(winner: Object.const_get("Country::#{winner}"), loser: Object.const_get("Country::#{loser}"))

    raise ArgumentError, "#{scores} is invalid values" if score.invalid? || (scores[0] + pk_flanse_score) == (scores[1] + pk_germany_score)

    score.save!
  end

  def self.results
    text = ''
    text << Score.total_matches
    scores = Score.all.order(id: 'DESC').limit(5)
    Score.match_result(scores, text)

    text << Score.total_wins
    text << Score.scoring_rate
    text << Score.total_scores
    text << Score.is_next_match?
  end
end
