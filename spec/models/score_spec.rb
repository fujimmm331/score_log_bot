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
end