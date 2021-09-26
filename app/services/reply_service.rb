class ReplyService
  def initialize(scores)
    @scores = scores
  end

  def call!
    ActiveRecord::Base.transaction do
      Score.save_from_message(@scores)
      match_score = Score.order(updated_at: :desc).limit(1)

      Wininng.update_count_of_winner_and_loser!(match_score.first.result.winner, match_score.first.result.loser)
      wininng = Wininng.find_by('count > ?', 1)

      make_reply_message(match_score, wininng)
    end
  end

  private
  def make_reply_message(match_score, wininng)
    reply_text = ''

    winner = match_score.first.result.winner.translate
    loser = match_score.first.result.loser.translate

    reply_text << make_result_content(winner, loser)

    if wininng.present?
      wininng_message = "#{wininng[:country] == Country::FLANCE ? 'フランス' : 'ドイツ'}は#{wininng[:count]}連勝中☺️" + "\n" + "\n"
      reply_text << wininng_message
    end

    Score.match_result(match_score, reply_text)
    reply_text << Score.total_matches
    reply_text << Score.total_wins
    reply_text << Score.scoring_rate
    reply_text << Score.total_scores
    reply_text << Score.is_next_match?
    reply_text
  end

  def make_result_content(winner, loser)
    fan_content = make_fan_content(loser)
    '🎉㊗️🎉㊗️🎉㊗️🎉㊗️' + "\n" + "㊗️🎉#{winner}の勝ち🎉㊗️" + "\n" + '🎉㊗️🎉㊗️🎉㊗️🎉㊗️' + "\n" + "\n" + "#{loser}は#{fan_content}" + "\n" + "\n"
  end

  # 煽りメッセージ作成処理
  def make_fan_content(loser)
    looser_legend = (loser == "フランス") ? get_flance_legend(rand(13)) : get_germany_legend(rand(13))
    fan_content = "#{looser_legend[:name]}をいれたほうがええんちゃう？？🤗"
    fan_content << "\n" + "あ！#{looser_legend[:country]}の選手やった☺️" if looser_legend[:country] != loser
    fan_content
  end

  def get_flance_legend(i)
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
    flance_legends[i]
  end

  def get_germany_legend(i)
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
    germany_legends[i]
  end
end
