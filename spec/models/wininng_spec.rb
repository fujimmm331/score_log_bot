require 'rails_helper'

RSpec.describe Wininng, type: :model do
  describe 'バリデーションテスト' do
    let :wininng do
      FactoryBot.build(:wininng)
    end

    it '保存できること' do
      expect(wininng).to be_valid
    end

    context '小数の時' do
      let :wininng do
        FactoryBot.build(
          :wininng,
          count: 1.2,
        )
      end

      it '保存できないこと' do
        expect(wininng).to be_invalid
      end
    end

    context '全角数字の時' do
      let :wininng do
        FactoryBot.build(
          :wininng,
          count: '０',
        )
      end

      it '保存できないこと' do
        expect(wininng).to be_invalid
      end
    end

    context 'ひらがなの時' do
      let :wininng do
        FactoryBot.build(
          :wininng,
          count: 'ぜろ',
        )
      end

      it '保存できないこと' do
        expect(wininng).to be_invalid
      end
    end

    context 'countが空の時' do
      let :wininng do
        FactoryBot.build(
          :wininng,
          count: nil,
        )
      end

      it '保存できないこと' do
        expect(wininng).to be_invalid
      end
    end

    context 'countryが空の時' do
      let :wininng do
        FactoryBot.build(
          :wininng,
          country: nil,
        )
      end

      it '保存できないこと' do
        expect(wininng).to be_invalid
      end
    end

    context 'countryが重複している時' do
      before :each do
        FactoryBot.create(:wininng)
      end

      it '保存できないこと' do
        expect(wininng).to be_invalid
      end
    end

    context 'countryに指定外の値が来た時' do
      let :wininng do
        FactoryBot.build(
          :wininng,
          country: 3,
        )
      end

      it '保存できないこと' do
        expect(wininng).to be_invalid
      end
    end
  end

  describe 'update_count_of_winner_and_loser!' do
    subject do
      Wininng.update_count_of_winner_and_loser!(winner, loser)
    end

    let :winner do
      Country::FLANCE
    end

    let :loser do
      Country::GERMANY
    end

    before :each do
      FactoryBot.create(:wininng)
      FactoryBot.create(:wininng, country: Country::GERMANY, count: 1)
    end

    it '勝者は連勝記録が1つ増えること' do
      expect{ subject }.to change{ Wininng.find_by(country: winner)[:count] }.from(0).to(1)
    end

    it '敗者は連勝記録が0になること' do
      expect{ subject }.to change{ Wininng.find_by(country: loser)[:count] }.from(1).to(0)
    end
  end
end
