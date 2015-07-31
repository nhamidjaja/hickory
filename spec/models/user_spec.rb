require 'rails_helper'

RSpec.describe User, type: :model do
  it { expect(FactoryGirl.build(:user)).to be_valid }

  describe 'after_save' do
    let(:user) { FactoryGirl.build(:user) }

    it do
      expect(user).to receive(:ensure_authentication_token)
      user.save
    end
  end

  describe '.username' do
    describe 'presence' do
      it { expect(FactoryGirl.build(:user, username: '')).to_not be_valid }
    end

    describe 'characters' do
      it { expect(FactoryGirl.build(:user, username: '!a')).to_not be_valid }
      it { expect(FactoryGirl.build(:user, username: 'a\n')).to_not be_valid }

      it { expect(FactoryGirl.build(:user, username: '_a')).to be_valid }
      it { expect(FactoryGirl.build(:user, username: '.a')).to be_valid }
      it { expect(FactoryGirl.build(:user, username: '12')).to be_valid }
    end

    describe 'capitalization' do
      it { expect(FactoryGirl.build(:user, username: 'xyZ')).to_not be_valid }
    end

    describe 'length' do
      it { expect(FactoryGirl.build(:user, username: '1' * 30)).to be_valid }
      it { expect(FactoryGirl.build(:user, username: '1')).to_not be_valid }
      it do
        expect(FactoryGirl.build(:user, username: '1' * 31))
          .to_not be_valid
      end
    end

    it 'is unique' do
      FactoryGirl.create(:user, username: 'nic')

      expect(FactoryGirl.build(:user, username: 'nic')).to_not be_valid
    end
  end

  describe '#from_third_party_auth' do
    let(:user) do
      FactoryGirl.build(:user,
                        email: 'a@b.com'
                       )
    end

    let(:auth) do
      instance_double('Fave::Auth',
                      email: 'a@b.com',
                      provider: 'fb',
                      uid: 'x123',
                      token: 'abc098')
    end

    subject { User.from_third_party_auth(auth) }

    context 'when email already exists' do
      it 'returns same user' do
        expect(User).to receive(:find_by_email).with('a@b.com').and_return(user)

        is_expected.to eq(user)
      end

      it 'updates user metadata' do
        expect(User).to receive(:find_by_email).with('a@b.com').and_return(user)

        expect(subject.provider).to eq('fb')
        expect(subject.uid).to eq('x123')
        expect(subject.omniauth_token).to eq('abc098')
      end
    end

    context 'when provider and uid already exists' do
      it 'leaves email alone' do
        user = FactoryGirl.create(:user, email: 'x@y.com',
                                         provider: 'fb', uid: 'x123')

        expect(User).to receive(:find_by_email).with('a@b.com').and_return(nil)
        expect(User).to receive(:find_by_provider_and_uid)
          .with('fb', 'x123')
          .and_return(user)

        expect(user.email).to eq('x@y.com')
        is_expected.to eq(user)
      end
    end

    context 'when new' do
      before do
        expect(User).to receive(:find_by_email).with('a@b.com').and_return(nil)
        expect(User).to receive(:find_by_provider_and_uid)
          .with('fb', 'x123')
          .and_return(nil)
      end

      it { is_expected.to be_a_new(User) }
      it { expect(subject.provider).to eq('fb') }
      it { expect(subject.uid).to eq('x123') }
      it { expect(subject.email).to eq('a@b.com') }
    end
  end

  describe '.password_required?' do
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

  describe '.ensure_authentication_token' do
    context 'blank token' do
      let(:user) { FactoryGirl.build(:user, authentication_token: '') }
      before { user.ensure_authentication_token }

      it 'sets token' do
        expect(user.authentication_token).to_not be_blank
      end
    end

    context 'token exists' do
      let(:user) { FactoryGirl.build(:user, authentication_token: 'abcdef') }
      before { user.ensure_authentication_token }

      it 'does nothing' do
        expect(user.authentication_token).to eq('abcdef')
      end
    end
  end

  describe '#search_by_username' do
    it { expect(User).to respond_to(:search_by_username) }
  end
end
