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
    it { expect(FactoryGirl.build(:user, username: '1' * 16)).to_not be_valid }

    it { expect(FactoryGirl.build(:user, username: '_a')).to be_valid }
    it { expect(FactoryGirl.build(:user, username: '.a')).to be_valid }
    it { expect(FactoryGirl.build(:user, username: '0')).to be_valid }

    it 'is unique' do
      FactoryGirl.create(:user, username: 'a')

      expect(FactoryGirl.build(:user, username: 'a')).to_not be_valid
    end
  end

  describe '#from_omniauth' do
    let(:callback) do
      { 'provider' => 'facebook', 'uid' => '123',
        'info' => { 'email' => 'a@b.com' },
        'credentials' => { 'token' => 'abc098' } }
    end

    subject { User.from_omniauth(callback) }

    context 'when email already exists' do
      it 'returns same user' do
        user = FactoryGirl.create(:user,
                                  email: 'a@b.com',
                                  provider: 'facebook', uid: '123')

        is_expected.to eq(user)
      end

      it 'updates user metadata' do
        FactoryGirl.create(:user, email: 'a@b.com')

        expect(subject.provider).to eq('facebook')
        expect(subject.uid).to eq('123')
        expect(subject.omniauth_token).to eq('abc098')
      end
    end

    context 'when provider and uid already exists' do
      it 'returns same user' do
        user = FactoryGirl.create(:user, email: 'x@y.com',
                                         provider: 'facebook', uid: '123')

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

  describe '#apply_omniauth' do
    let(:callback) do
      { 'provider' => 'facebook', 'uid' => '123',
        'info' => { 'email' => 'a@b.com' },
        'credentials' => { 'token' => 'abc098' } }
    end
    before { user.apply_omniauth(callback) }

    context 'new user' do
      subject(:user) { FactoryGirl.build(:user) }

      it { expect(user.provider).to eq('facebook') }
      it { expect(user.uid).to eq('123') }
      it { expect(user.email).to eq('a@b.com') }
      it { expect(user.omniauth_token).to eq('abc098') }
    end

    context 'existing user' do
      subject(:user) { FactoryGirl.create(:user, email: 'do-not@change.com') }

      it { expect(user.email).to eq('do-not@change.com') }
    end
  end

  describe '#password_required?' do
    subject { user.send(:password_required?) }

    context 'no provider' do
      let(:user) { FactoryGirl.build(:user, provider: '', password: '') }

      it { is_expected.to eq(true) }
    end

    context 'no uid' do
      let(:user) { FactoryGirl.build(:user, uid: '', password: '') }

      it { is_expected.to eq(true) }
    end

    context 'has provider and uid' do
      let(:user) do
        FactoryGirl.build(:user, password: '',
                                 provider: 'oauth', uid: '321')
      end

      it { is_expected.to eq(false) }
    end

    context 'has a password' do
      let(:user) { FactoryGirl.build(:user, password: 'whatever') }

      it { is_expected.to eq(true) }
    end
  end

  describe '#valid_token?' do
    let(:user) { FactoryGirl.build(:user, omniauth_token: 'saved-token') }

    context 'same token already saved' do
      subject { user.valid_token?('saved-token') }

      it { is_expected.to eq(true) }
    end

    context 'different but valid token' do
      before do
        fb_user = instance_double('FbGraph2::User', access_token: 'remote-token')
        expect_any_instance_of(FbGraph2::User).to receive(:fetch).and_return(fb_user)
      end

      subject { user.valid_token?('client-token') }

      it { is_expected.to eq(true) }
    end

    context 'different but invalid third-party token' do
      before do
        double = instance_double('FbGraph2::User', access_token: 'alsovalid')
        allow(double).to receive(:fetch).and_raise(FbGraph2::Exception::InvalidToken, 'invalid token')

        allow(FbGraph2::User).to receive(:me).and_return(double)
      end

      subject { user.valid_token?('sometoken') }

      it { is_expected.to eq(false) }
    end
  end
end
