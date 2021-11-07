class Score < ApplicationRecord
  has_one :result
  with_options presence: true do
    validates :france
    validates :germany
    validates :france_pk
    validates :germany_pk
  end
  
  with_options numericality: { only_integer: true } do
    validates :france
    validates :germany
    validates :france_pk
    validates :germany_pk
  end

  def self.total_wins
    return '【勝ち数】' + "\n" + 'フランス：' + Score.where("france + france_pk > germany + germany_pk").count.to_s + '勝' + "\n" + 'ドイツ　：' + Score.where("france + france_pk < germany + germany_pk").count.to_s + '勝' + "\n" + "\n"
  end

  def self.scoring_rate
    return '【得点率】' + "\n" + 'フランス：' + ' ' + Score.average(:france).round(1).to_s + '点' + "\n" + 'ドイツ　：' + ' ' + Score.average(:germany).round(1).to_s + '点' + "\n" + "\n"
  end

  def self.total_scores
    total_france_score = Score.sum(:france)
    total_germany = Score.sum(:germany)
    return '【総得点】' + "\n" + 'フランス：' + ' ' + total_france_score.to_s + '点' + "\n" + 'ドイツ　：' + ' ' + total_germany.to_s + '点' + "\n" + '合計　　：' + ' ' + (total_france_score + total_germany).to_s + '点' + "\n" + "\n"
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
      text << score[:france].to_s + ' ' + '-' + ' ' + score[:germany].to_s
      text << '（' + ' ' + score[:france_pk].to_s + ' ' + '-' + ' ' + score[:germany_pk].to_s + ' ' + '）' unless (score[:france_pk] == 0 && score[:germany_pk] == 0)
      text << "\n"
    end
    text << "\n"
  end

  def self.save_from_message(scores)
    # pk戦じゃなければ0を代入する
    if scores.length == 2
      pk_flanse_score = 0
      germany_pk = 0
    end

    if scores.length == 4
      pk_flanse_score = scores[2]
      germany_pk = scores[3]
    end

    raise ArgumentError, "#{scores} is invalid length" unless scores.length == 2 || scores.length == 4

    winner = (scores[0] + pk_flanse_score > scores[1] + germany_pk) ? "FRANCE" : "GERMANY"
    loser = (winner == "FRANCE") ? "GERMANY" : "FRANCE"
    score = Score.new(france: scores[0], germany: scores[1], france_pk: pk_flanse_score, germany_pk: germany_pk)
    result = score.build_result(winner: Object.const_get("Country::#{winner}"), loser: Object.const_get("Country::#{loser}"))

    raise ArgumentError, "#{scores} is invalid values" if score.invalid? || (scores[0] + pk_flanse_score) == (scores[1] + germany_pk)

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
