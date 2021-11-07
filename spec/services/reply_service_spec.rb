require 'rails_helper'

RSpec.describe ReplyService do
  describe 'インスタンス' do
    subject do
      described_class.new(scores)
    end

    let :scores do
      [1, 2]
    end

    let :match_score do
      Score.order(updated_at: :desc).limit(1)
    end

    let :wininng do
      Wininng.find_by(country: Country::FRANCE)
    end

    before :each do
      FactoryBot.create(
        :wininng,
        count: 1,
      )

      FactoryBot.create(
        :wininng,
        country: Country::GERMANY,
        count: 0,
      )

      FactoryBot.create(:result)
    end

    it 'インスタンスを返すこと' do
      expect(subject).to be_instance_of(described_class)
    end

    describe 'call' do
      subject do
        reply = described_class.new(scores)
        reply.call!
      end

      before :each do
        allow(Score).to receive(:save_from_message)
          .with(scores)

        allow(Score).to receive_message_chain(:order, :limit)
          .with(updated_at: :desc)
          .with(1)
          .and_return(match_score)

        allow(Wininng).to receive(:update_count_of_winner_and_loser!)
          .with(match_score.first.result.winner, match_score.first.result.loser)

        allow(Wininng).to receive(:find_by)
          .with('count > ?', 1)
      end

      it 'スコアが保存される処理がよばれること' do
        expect(Score).to receive(:save_from_message).once
        subject
      end

      it '保存したスコアを取得する処理が呼ばれること' do
        expect(Score).to receive_message_chain(:order, :limit)
          .with(updated_at: :desc)
          .with(1)
        subject
      end

      it '連勝記録を更新するメソッドが呼び出されること' do
        expect(Wininng).to receive(:update_count_of_winner_and_loser!)
          .with(match_score.first.result.winner, match_score.first.result.loser)
        subject
      end

      it '連勝記録が2以上のレコードを取得するメソッドが呼び出されること' do
        expect(Wininng).to receive(:find_by)
          .with('count > ?', 1)
        subject
      end
    end

    describe 'make_reply_message' do
      subject do
        instance.send(:make_reply_message, match_score, wininng)
      end

      let :instance do
        described_class.new(scores)
      end

      before :each do
        wininng = nil
      end

      it '勝敗が含まれること' do
        expect(subject).to include 'フランスの勝ち'
        expect(subject).to include 'ドイツは'
      end

      it '煽りメッセージが含まれること' do
        expect(subject).to include 'をいれたほうがええんちゃう？？'
      end

      it '総試合数が含まれること' do
        expect(subject).to include "#{Score.count}試合"
      end

      it '両国のトータル勝利数が含まれること' do
        expect(subject).to include "フランス：#{Score.where("france + france_pk > germany + germany_pk").count}勝"
        expect(subject).to include "ドイツ　：#{Score.where("france + france_pk < germany + germany_pk").count}勝"
      end

      it '両国の得点率が含まれること' do
        expect(subject).to include "フランス： #{Score.average(:france).round(1).to_s}"
        expect(subject).to include "ドイツ　： #{Score.average(:germany).round(1).to_s}"
      end

      it '両国の総得点が含まれること' do
        expect(subject).to include "フランス： #{Score.sum(:france)}"
        expect(subject).to include "ドイツ　： #{Score.sum(:germany)}"
      end

      it '次はどっちが勝つかな？ が含まれること' do
        expect(subject).to include "次はどっちが勝つかな？"
      end

      context '連勝記録がある時' do
        before :each do
          wininng.update(count: 2)
        end

        it '連勝記録が含まれること' do
          expect(subject).to include 'フランスは2連勝中'
        end
      end
    end
  end
end