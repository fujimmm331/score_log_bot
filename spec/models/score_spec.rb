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
  end
end