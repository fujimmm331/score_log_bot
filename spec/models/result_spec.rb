require 'rails_helper'

RSpec.describe Result, type: :model do
  describe 'resultモデルのテスト' do
    let :result do
      FactoryBot.create(
        :result,
      )
    end

    it '保存できること' do
      expect(result).to be_valid
    end

    context 'winnerが空の時' do
      before :each do
        result[:winner] = nil
      end

      it '保存できないこと' do
        expect(result).to be_invalid
      end
    end

    context 'loserが空の時' do
      before :each do
        result[:loser] = nil
      end

      it '保存できないこと' do
        expect(result).to be_invalid
      end
    end

    context 'score_idが空の時' do
      before :each do
        result[:score_id] = nil
      end

      it '保存できないこと' do
        expect(result).to be_invalid
      end
    end

    context 'winnerに規定外の値がきた時' do
      subject do
        FactoryBot.create(
          :result,
          winner: 2
        )
      end

      it '保存できないこと' do
        expect{subject}.to raise_error(ArgumentError)
      end
    end
  end
end
