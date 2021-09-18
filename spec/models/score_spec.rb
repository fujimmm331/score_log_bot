require 'rails_helper'

RSpec.describe Score, type: :model do
  describe 'スコアモデルテスト' do
    before do
      @score = FactoryBot.build(:score)
    end
    context '保存できる時' do
      it 'スコアが全て埋まっていれば保存できる' do
        expect(@score).to be_valid
      end
    end

    context '保存できない時' do
      it 'フランスのスコアが空では保存できない' do
        @score.franse_score = nil
        @score.valid?
        expect(@score.errors.full_messages).to include "Franse score can't be blank"
      end

      it 'ドイツのスコアが空では保存できない' do
        @score.germany_score = nil
        @score.valid?
        expect(@score.errors.full_messages).to include "Germany score can't be blank"
      end

      it 'フランスのpkのスコアが空では保存できない' do
        @score.pk_franse_score = nil
        @score.valid?
        expect(@score.errors.full_messages).to include "Pk franse score can't be blank"
      end

      it 'ドイツのpkのスコアが空では保存できない' do
        @score.pk_germany_score = nil
        @score.valid?
        expect(@score.errors.full_messages).to include "Pk germany score can't be blank"
      end

      it 'フランスのスコアは数字以外保存できない' do
        @score.franse_score = '２'
        @score.valid?
        expect(@score.errors.full_messages).to include "Franse score is not a number"
      end

      it 'ドイツのスコアは数字以外保存できない' do
        @score.germany_score = '２'
        @score.valid?
        expect(@score.errors.full_messages).to include "Germany score is not a number"
      end

      it 'フランスのpkのスコアは数字以外保存できない' do
        @score.pk_franse_score = '２'
        @score.valid?
        expect(@score.errors.full_messages).to include "Pk franse score is not a number"
      end

      it 'ドイツのpkのスコアは数字以外保存できない' do
        @score.pk_germany_score = '２'
        @score.valid?
        expect(@score.errors.full_messages).to include "Pk germany score is not a number"
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
        expect(score[:franse_score]).to eq(scores[0])
        expect(score[:germany_score]).to eq(scores[1])
        expect(score[:pk_franse_score]).to eq(0)
        expect(score[:pk_germany_score]).to eq(0)
      end

      it '勝敗も保存されること' do
        expect{subject}.to change(Result, :count).by(1)
      end

      it '保存された勝敗のレコードが正しいこと' do
        subject
        result = Result.order(updated_at: :desc).limit(1).first
        expect(result[:winner]).to eq(Country::FLANCE)
        expect(result[:loser]).to eq(Country::GERMANY)
      end

      it '得点, 総試合数, 勝ち数, 得点率, 総得点が含まれること' do
        expect(subject).to include "【得点】"
        expect(subject).to include "【総試合数】"
        expect(subject).to include "【勝ち数】"
        expect(subject).to include "【得点率】"
        expect(subject).to include "【総得点】"
      end

      it '総得点が.resultと同じこと' do
        message = ""
        expect(subject).to include message
        results = Score.results
        expect(results).to include message
      end

      it '総試合数が.resultと同じこと' do
        message = "【総試合数】\n1試合"
        expect(subject).to include message
        results = Score.results
        expect(results).to include message
      end

      context 'フランスが勝ちの時' do
        it 'フランスの勝ちが含まれること' do
          expect(subject).to include "フランスの勝ち"
        end
      end

      context 'ドイツが勝ちの時' do
        let :scores do
          [0, 3]
        end

        it 'ドイツの勝ちが含まれること' do
          expect(subject).to include "ドイツの勝ち"
        end
      end
    end

    context 'scoresが3桁できた時' do
      let :scores do
        [3, 2, 1]
      end

      it '保存されないこと' do
        expect{subject}.to change(Score, :count).by(0)
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
        expect(score[:franse_score]).to eq(scores[0])
        expect(score[:germany_score]).to eq(scores[1])
        expect(score[:pk_franse_score]).to eq(scores[2])
        expect(score[:pk_germany_score]).to eq(scores[3])
      end

      it '勝敗も保存されること' do
        expect{subject}.to change(Result, :count).by(1)
      end

      it '保存された勝敗のレコードが正しいこと' do
        subject
        result = Result.order(updated_at: :desc).limit(1).first
        expect(result[:winner]).to eq(Country::FLANCE)
        expect(result[:loser]).to eq(Country::GERMANY)
      end

      it '得点, 総試合数, 勝ち数, 得点率, 総得点が含まれること' do
        expect(subject).to include "【得点】"
        expect(subject).to include "【総試合数】"
        expect(subject).to include "【勝ち数】"
        expect(subject).to include "【得点率】"
        expect(subject).to include "【総得点】"
      end

      context 'フランスが勝ちの時' do
        let :scores do
          [3, 3, 2, 1]
        end

        it 'フランスの勝ちが含まれること' do
          expect(subject).to include "フランスの勝ち"
        end
      end

      context 'ドイツが勝ちの時' do
        let :scores do
          [3, 3, 1, 2]
        end

        it 'ドイツの勝ちが含まれること' do
          expect(subject).to include "ドイツの勝ち"
        end
      end

      context 'flance_scoreとgermany_scoreが等しくない場合' do
        let :scores do
          [3, 2, 1, 2]
        end

        it 'スコアが保存されないこと' do
          expect{subject}.to change(Score, :count).by(0)
        end
      end

      context 'scores内の要素が全て等しい場合' do
        let :scores do
          [3, 3, 3, 3]
        end

        it 'スコアが保存されないこと' do
          expect{subject}.to change(Score, :count).by(0)
        end
      end
    end

    context '連勝の時' do
      before :each do
        FactoryBot.create(:score,
          franse_score: 3,
          germany_score: 2,
          pk_franse_score: 0,
          pk_germany_score: 0
        )

        FactoryBot.create(:wininng,
          country: Country::GERMANY
        )

        FactoryBot.create(:wininng,
          count: 1
        )
      end
      let :scores do
        [3, 2]
      end

      it '連勝数が含まれること' do
        subject
        expect(subject).to include "2連勝"
      end
    end
  end
end