require 'rails_helper'

RSpec.describe Score, type: :model do
  describe 'スコアモデルテスト' do
    let :score do
      FactoryBot.build(:score)
    end

    describe 'バリデーション' do
      context '保存できる時' do
        it 'スコアが全て埋まっていれば保存できる' do
          expect(score).to be_valid
        end
      end
  
      context '保存できない時' do
        it 'フランスのスコアが空では保存できない' do
          score.france = nil
          expect(score).to be_invalid
        end
  
        it 'ドイツのスコアが空では保存できない' do
          score.germany = nil
          expect(score).to be_invalid
        end
  
        it 'フランスのpkのスコアが空では保存できない' do
          score.france_pk = nil
          expect(score).to be_invalid
        end
  
        it 'ドイツのpkのスコアが空では保存できない' do
          score.germany_pk = nil
          expect(score).to be_invalid
        end
  
        it 'フランスのスコアは数字以外保存できない' do
          score.france = '２'
          expect(score).to be_invalid
        end
  
        it 'ドイツのスコアは数字以外保存できない' do
          score.germany = '２'
          expect(score).to be_invalid
        end
  
        it 'フランスのpkのスコアは数字以外保存できない' do
          score.france_pk = '２'
          expect(score).to be_invalid
        end
  
        it 'ドイツのpkのスコアは数字以外保存できない' do
          score.germany_pk = '２'
          expect(score).to be_invalid
        end
      end
    end
  end

  describe 'save_from_message' do
    subject do
      Score.save_from_message(scores)
    end

    context 'scoresが2桁できた時' do
      let :scores do
        [3, 2]
      end

      it '保存されること' do
        expect{subject}.to change(Score, :count).by(1)
      end

      it '保存されたレコードが正しいこと' do
        subject
        score = Score.order(updated_at: :desc).limit(1).first
        expect(score[:france]).to eq(scores[0])
        expect(score[:germany]).to eq(scores[1])
        expect(score[:france_pk]).to eq(0)
        expect(score[:germany_pk]).to eq(0)
      end

      it '勝敗も保存されること' do
        expect{subject}.to change(Result, :count).by(1)
      end

      it '保存された勝敗のレコードが正しいこと' do
        subject
        result = Result.order(updated_at: :desc).limit(1).first
        expect(result[:winner]).to eq(Country::FRANCE)
        expect(result[:loser]).to eq(Country::GERMANY)
      end
    end

    context 'scoresが3桁できた時' do
      let :scores do
        [3, 2, 1]
      end

      it 'ArgumentError が発生すること' do
        expect{subject}.to raise_error(ArgumentError)
      end
    end

    context 'scoresが4桁できた時' do
      let :scores do
        [3, 3, 2, 1]
      end

      it '保存されること' do
        expect{subject}.to change(Score, :count).by(1)
      end

      it '保存されたレコードが正しいこと' do
        subject
        score = Score.order(updated_at: :desc).limit(1).first
        expect(score[:france]).to eq(scores[0])
        expect(score[:germany]).to eq(scores[1])
        expect(score[:france_pk]).to eq(scores[2])
        expect(score[:germany_pk]).to eq(scores[3])
      end

      it '勝敗も保存されること' do
        expect{subject}.to change(Result, :count).by(1)
      end

      it '保存された勝敗のレコードが正しいこと' do
        subject
        result = Result.order(updated_at: :desc).limit(1).first
        expect(result[:winner]).to eq(Country::FRANCE)
        expect(result[:loser]).to eq(Country::GERMANY)
      end

      context 'france_scoreとgermanyが等しくない場合' do
        let :scores do
          [3, 2, 1, 2]
        end

        it 'ArgumentError が発生すること' do
          expect{subject}.to raise_error(ArgumentError)
        end
      end

      context 'scores内の要素が全て等しい場合' do
        let :scores do
          [3, 3, 3, 3]
        end

        it 'ArgumentError が発生すること' do
          expect{subject}.to raise_error(ArgumentError)
        end
      end
    end
  end

  describe 'total_wins' do
    subject do
      Score.total_wins
    end

    it 'フランスの勝利数が含まれること' do
      expect(subject).to include "フランス：#{Score.where("france + france_pk > germany + germany_pk").count.to_s}"
    end

    it 'ドイツの勝利数が含まれること' do
      expect(subject).to include "ドイツ　：#{Score.where("france + france_pk < germany + germany_pk").count.to_s}"
    end
  end

  describe 'scoring_rate' do
    subject do
      Score.scoring_rate
    end

    before :each do
      7.times do
        FactoryBot.create(:score)
      end
    end

    it 'フランスの勝利数が含まれること' do
      expect(subject).to include "フランス： #{Score.average(:france).round(1).to_s}"
    end

    it 'ドイツの勝利数が含まれること' do
      expect(subject).to include "ドイツ　： #{Score.average(:germany).round(1).to_s}"
    end
  end

  describe 'total_scores' do
    subject do
      Score.total_scores
    end

    before :each do
      10.times do
        FactoryBot.create(:score)
      end
    end

    it 'フランスの勝利数が含まれること' do
      expect(subject).to include "フランス： #{Score.sum(:france)}"
    end

    it 'ドイツの勝利数が含まれること' do
      expect(subject).to include "ドイツ　： #{Score.sum(:germany)}"
    end
  end

  describe 'total_matches' do
    subject do
      Score.total_matches
    end

    before :each do
      10.times do
        FactoryBot.create(:score)
      end
    end

    it '総試合数が含まれること' do
      expect(subject).to include Score.count.to_s
    end
  end

  describe 'is_next_match?' do
    subject do
      Score.is_next_match?
    end

    it '次はどっちが勝つかな？ が含まれること' do
      expect(subject).to include "次はどっちが勝つかな？"
    end

    context '次が10試合目の時' do
      before :each do
        9.times do
          FactoryBot.create(:score)
        end
      end

      it '記念すべき10試合目が含まれること' do
        expect(subject).to include "次は記念すべき10試合目やでぇ！！"
      end
    end
  end

  describe 'match_result()' do
    subject do
      Score.match_result(scores, text)
    end

    let :scores do
      [FactoryBot.create(:score)]
    end

    let :text do
      ''
    end

    it '【得点】 が含まれること' do
      expect(subject).to include "【得点】"
    end

    context 'scoresの長さが2以上の時' do
      let :scores do
        [FactoryBot.create(:score), FactoryBot.create(:score)]
      end

      it '【直近５試合の結果】が含まれること' do
        expect(subject).to include "【直近５試合の結果】"
      end
    end
  end
end