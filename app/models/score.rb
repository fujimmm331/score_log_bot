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
    return '【勝ち数】' + "\n" + 'フランス：' + Score.where("franse_score + pk_franse_score > germany_score + pk_germany_score").count.to_s + '勝' + "\n" + 'ドイツ　：' + Score.where("franse_score + pk_franse_score < germany_score + pk_germany_score").count.to_s + '勝' + "\n" + "\n"
  end

  def self.scoring_rate
    return '【得点率】' + "\n" + 'フランス：' + ' ' + Score.average(:franse_score).round(1).to_s + '点' + "\n" + 'ドイツ　：' + ' ' + Score.average(:germany_score).round(1).to_s + '点' + "\n" + "\n"
  end

  def self.total_scores
    total_flance_score = Score.sum(:franse_score)
    total_germany_score = Score.sum(:germany_score)
    return '【得点】' + "\n" + 'フランス：' + ' ' + total_flance_score.to_s + '点' + "\n" + 'ドイツ　：' + ' ' + total_germany_score.to_s + '点' + "\n" + '合計　　：' + ' ' + (total_flance_score + total_germany_score).to_s + '点' + "\n" + "\n"
  end

  def self.total_matches
    return '【総試合数】' + "\n" +  Score.count.to_s + '試合' + "\n" + "\n"
  end

  def self.is_memorial_match?
    next_matche = Score.count + 1
    (next_matche % 10 == 0) ? "次は記念すべき#{next_matche}試合目やでぇ！！" : "次はどっちが勝つかな!?!?!?"
  end

  def self.saved_from_message(params)
    scores = params.split(" ").map!(&:to_i)
    score = Score.new(franse_score: scores[0], germany_score: scores[1], pk_franse_score: scores[2], pk_germany_score: scores[3])

    if score.valid? && (scores[0] + scores[2]) != (scores[1] + scores[3])
      score.save
      winner = (scores[0] + scores[2] > scores[1] + scores[3]) ? "フランス" : "ドイツ"
      loser = (winner == "フランス") ? "ドイツ" : "フランス"
      matches = Score.count
      memorial_match = "記念すべき「#{matches}試合目」" + "\n" + "の結果は、、、" + "\n" + "\n"

      # 負けた方への煽りメッセージ
      flance_legends = ["ジダン", "ベンゼマ", "アンリ", "リベリー", "ジブリルシセ", "ネイマール", "ディマリア", "ロナウジーニョ", "ベッカム", "ヴェッラッティ", "カヴァーニ", "イブラヒモヴィッチ", "ヴィエラ"]
      germany_legends = ["ミュラー", "レヴァンドフスキ", "ロッペン", "マリオゴメス", "シュヴァインシュタイガー", "ラーム", "アラバ", "パヴァール", "ゲッチェ", "クローゼ", "チアゴ・アルカンタラ", "宇佐美貴史", "オリバーカーン"]
      looser_legends = (loser == "フランス") ? flance_legends : germany_legends
      fan_content = "#{looser_legends[rand(13)]}をいれたほうがええんちゃう？？"
      
      result = '🎉㊗️🎉㊗️🎉㊗️🎉㊗️' + "\n" + "㊗️🎉#{winner}の勝ち🎉㊗️" + "\n" + '🎉㊗️🎉㊗️🎉㊗️🎉㊗️' + "\n" + "\n" + "#{loser}は#{fan_content}🤗" + "\n" + "\n"

      text = ''
      text << memorial_match if matches % 10 == 0
      text << result
      text << Score.total_matches
      text << Score.total_wins
      text << Score.scoring_rate
      text << Score.total_scores
      text << Score.is_memorial_match?

    elsif (scores[0] + scores[2]) == (scores[1] + scores[3])
      "必ず勝ち負けがつくはすやでぇ..."
    else
      '失敗。。スコアは半角数字、半角スペースで送ってね！'
    end
  end

  def self.result
    text = ''
    text << Score.total_matches

    text << '【直近５試合の結果】' + "\n"
    scores = Score.all.order(id: 'DESC').limit(5)
    scores.each do |score|
      text << score[:franse_score].to_s + ' ' + '-' + ' ' + score[:germany_score].to_s
      text <<'（' + ' ' + score[:pk_franse_score].to_s + ' ' + '-' + ' ' + score[:pk_germany_score].to_s + ' ' + '）' unless (score[:pk_franse_score] == 0 && score[:pk_germany_score] == 0)
      text << "\n"
    end
    text << "\n"

    text << Score.total_wins
    text << Score.scoring_rate
    text << Score.total_scores
    text << Score.is_memorial_match?
  end
end
