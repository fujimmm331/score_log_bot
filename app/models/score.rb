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
    elsif scores.length == 4
      pk_flanse_score = scores[2]
      pk_germany_score = scores[3]
    else
      return "そいつは無効な値だわ！"
    end

    winner = (scores[0] + pk_flanse_score > scores[1] + pk_germany_score) ? "フランス" : "ドイツ"
    loser = (winner == "フランス") ? "ドイツ" : "フランス"

    score = Score.new(franse_score: scores[0], germany_score: scores[1], pk_franse_score: pk_flanse_score, pk_germany_score: pk_germany_score)
    result = score.build_result(winner: winner, loser: loser)
    return "そいつぁあかんなあ！半角数字で送るんやでえ！あと必ず勝ち負けがつくはずやでえ！" if score.invalid? || (scores[0] + pk_flanse_score) == (scores[1] + pk_germany_score)
    score.save

    # 負けた方への煽りメッセージ作成
    flance_legends = [
      {
        name: "ジダン",
        country: "フランス"
      },
      {
        name: "ベンゼマ",
        country: "フランス"
      },
      {
        name: "アンリ",
        country: "フランス"
      },
      {
        name: "リベリー",
        country: "フランス"
      },
      {
        name: "ジブリルシセ",
        country: "フランス"
      },
      {
        name: "ネイマール",
        country: "ブラジル"
      },
      {
        name: "ディマリア",
        country: "アルゼンチン"
      },
      {
        name: "ロナウジーニョ",
        country: "ブラジル"
      },
      {
        name: "ベッカム",
        country: "イングランド"
      },
      {
        name: "ヴェッラッティ",
        country: "イタリア"
      },
      {
        name: "カバーニ",
        country: "ウルグアイ"
      },
      {
        name: "イブラヒモヴィッチ",
        country: "スウェーデン"
      },
      {
        name: "ヴィエラ",
        country: "フランス"
      },
    ]
    germany_legends = [
      {
        name: "ミュラー",
        country: "ドイツ"
      },
      {
        name: "マリオゴメス",
        country: "ドイツ"
      },
      {
        name: "シュヴァインシュタイガー",
        country: "ドイツ"
      },
      {
        name: "ラーム",
        country: "ドイツ"
      },
      {
        name: "ゲッチェ",
        country: "ドイツ"
      },
      {
        name: "クローゼ",
        country: "ドイツ"
      },
      {
        name: "オリバーカーン",
        country: "ドイツ"
      },
      {
        name: "レヴァンドフスキ",
        country: "ポーランド"
      },
      {
        name: "ロッペン",
        country: "オランダ"
      },
      {
        name: "アラバ",
        country: "オーストリア"
      },
      {
        name: "パヴァール",
        country: "フランス"
      },
      {
        name: "チアゴ・アルカンタラ",
        country: "スペイン"
      },
      {
        name: "宇佐美貴史",
        country: "日本"
      },
    ]
    looser_legend = (loser == "フランス") ? flance_legends[rand(13)] : germany_legends[rand(13)]
    fan_content = "#{looser_legend[:name]}をいれたほうがええんちゃう？？🤗"
    fan_content << "\n" + "あ！#{looser_legend[:country]}の選手やった☺️" if looser_legend[:country] != loser

    # botで返信する内容を決める処理
    result = '🎉㊗️🎉㊗️🎉㊗️🎉㊗️' + "\n" + "㊗️🎉#{winner}の勝ち🎉㊗️" + "\n" + '🎉㊗️🎉㊗️🎉㊗️🎉㊗️' + "\n" + "\n" + "#{loser}は#{fan_content}" + "\n" + "\n"
    scores = Score.order(updated_at: :desc).limit(1)

    text = ''
    text << result
    Score.match_result(scores, text)
    text << Score.total_matches
    text << Score.total_wins
    text << Score.scoring_rate
    text << Score.total_scores
    text << Score.is_next_match?
    text
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
