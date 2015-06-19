require 'rails_helper'

RSpec.describe User, type: :model do
  it 'has a valid factory' do
    expect(FactoryGirl.create(:user)).to be_valid
  end

  describe '.username' do
    it { expect(FactoryGirl.build(:user, username: '')).to_not be_valid }
    it { expect(FactoryGirl.build(:user, username: '!a')).to_not be_valid }
    it { expect(FactoryGirl.build(:user, username: 'a\n')).to_not be_valid }
    it { expect(FactoryGirl.build(:user, username: 'xyZ')).to_not be_valid }
    it { expect(FactoryGirl.build(:user, username: '1234567890123456')).to_not be_valid }


    it { expect(FactoryGirl.build(:user, username: '_a')).to be_valid }
    it { expect(FactoryGirl.build(:user, username: '.a')).to be_valid }
    it { expect(FactoryGirl.build(:user, username: '0')).to be_valid }

    it 'is unique' do
      FactoryGirl.create(:user, username: 'a')

      expect(FactoryGirl.build(:user, username: 'a')).to_not be_valid
    end
  end

  describe '#from_omniauth' do
    let(:info) { double(email: 'a@b.com') }
    let(:credentials) { double(token: 'abc098') }
    let(:callback) { double(provider: 'facebook', uid: '123', info: info, credentials: credentials) }

    subject { User.from_omniauth(callback) }

    context 'when email already exists' do
      it 'returns same user' do
        user = FactoryGirl.create(:user, email: 'a@b.com', provider: 'facebook', uid: '123')
        
        is_expected.to eq(user)
      end

      it 'updates user metadata' do
        user = FactoryGirl.create(:user, email: 'a@b.com')
        
        expect(subject.provider).to eq('facebook')
        expect(subject.uid).to eq('123')
        expect(subject.omniauth_token).to eq('abc098')
      end
    end

    context 'when provider and uid already exists' do
      it 'returns same user' do
        user = FactoryGirl.create(:user, email: 'x@y.com', provider: 'facebook', uid: '123')
        
        is_expected.to eq(user)
      end
    end

    context 'when new' do
      it { is_expected.to be_a_new(User) }
      it { expect(subject.provider).to eq('facebook') }
      it { expect(subject.uid).to eq('123') }
      it { expect(subject.email).to eq('a@b.com') }
    end
  end
end
