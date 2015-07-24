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
    it { expect(FactoryGirl.build(:user, username: '1' * 31)).to_not be_valid }
    it { expect(FactoryGirl.build(:user, username: 'a')).to_not be_valid }

    it { expect(FactoryGirl.build(:user, username: '_a')).to be_valid }
    it { expect(FactoryGirl.build(:user, username: '.a')).to be_valid }
    it { expect(FactoryGirl.build(:user, username: '1' * 30)).to be_valid }

    it 'is unique' do
      FactoryGirl.create(:user, username: 'nic')

      expect(FactoryGirl.build(:user, username: 'nic')).to_not be_valid
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

  describe '#from_third_party_auth' do
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
        user = FactoryGirl.create(:user,
                                  email: 'a@b.com',
                                  provider: 'fb', uid: 'x123')

        is_expected.to eq(user)
      end

      it 'updates user metadata' do
        FactoryGirl.create(:user, email: 'a@b.com')

        expect(subject.provider).to eq('fb')
        expect(subject.uid).to eq('x123')
        expect(subject.omniauth_token).to eq('abc098')
      end
    end

    context 'when provider and uid already exists' do
      it 'returns same user' do
        user = FactoryGirl.create(:user, email: 'x@y.com',
                                         provider: 'fb', uid: 'x123')

        subject.save
        user.reload
        expect(user.email).to eq('x@y.com')
        is_expected.to eq(user)
      end
    end

    context 'when new' do
      it { is_expected.to be_a_new(User) }
      it { expect(subject.provider).to eq('fb') }
      it { expect(subject.uid).to eq('x123') }
      it { expect(subject.email).to eq('a@b.com') }
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

  describe '.ensure_authentication_token' do
    it do
      expect(FactoryGirl.build(:user, authentication_token: '')
      .ensure_authentication_token).to_not be_blank
    end
    it do
      expect(FactoryGirl.create(:user, authentication_token: '')
      .authentication_token).to_not be_blank
    end
  end

  describe '.get_facebook_friends' do
    let(:user) { FactoryGirl.create(:user, omniauth_token: "token") }
    subject {user.get_facebook_friends}
    context 'no friend' do
      before do
        fb_user = instance_double('FbGraph2::User')
        fb_response = instance_double('FbGraph2::User',
          friends: [])

        expect(FbGraph2::User).to receive(:me).with('token').and_return(fb_user)
        expect(fb_user).to receive(:fetch).and_return(fb_response)
      end

      it 'has 0 user_friends' do
        subject

        expect(user.user_friends.size).to eq(0)
      end
    end

    context '1 friend' do
      before do
        fb_user = instance_double('FbGraph2::User')
        fb_response = instance_double('FbGraph2::User',
          friends: [
            instance_double('FbGraph2::User',id: 1)
            ])

        expect(FbGraph2::User).to receive(:me).with('token').and_return(fb_user)
        expect(fb_user).to receive(:fetch).and_return(fb_response)
      end

      context 'no existing friends' do
        it 'has 1 user_friends' do
          subject

          expect(user.user_friends.size).to eq(1)
        end
      end
    end

    context 'more 1 friend' do
      before do
        fb_user = instance_double('FbGraph2::User')
        fb_response = instance_double('FbGraph2::User',
          friends: [
            instance_double('FbGraph2::User',id: 1),
            instance_double('FbGraph2::User',id: 2),
            instance_double('FbGraph2::User',id: 3)
            ])

        expect(FbGraph2::User).to receive(:me).with('token').and_return(fb_user)
        expect(fb_user).to receive(:fetch).and_return(fb_response)
      end

      it 'has 1 user_friends' do
        subject

        expect(user.user_friends.size).to eq(3)
      end
    end
  end
end
