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

      expect(FactoryGirl.build(:user, username: 'NIC')).to_not be_valid
    end

    describe 'setter' do
      it do
        expect(FactoryGirl.build(:user, username: 'xyZ').username)
          .to eq('xyz')
      end
    end
  end

  describe '.description' do
    describe 'getter' do
      it do
        expect(FactoryGirl.build(:user, description: nil).description).to eq('')
      end
    end
  end

  describe '#search' do
    it { expect(User).to respond_to(:search) }
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
                      token: 'abc098',
                      full_name: 'John Doe'
                     )
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
      it 'leaves email and full name alone' do
        user = FactoryGirl.build(:user,
                                 email: 'x@y.com',
                                 provider: 'fb',
                                 uid: 'x123',
                                 full_name: 'Do not change'
                                )

        expect(User).to receive(:find_by_email).with('a@b.com').and_return(nil)
        expect(User).to receive(:find_by_provider_and_uid)
          .with('fb', 'x123')
          .and_return(user)

        expect(user.email).to eq('x@y.com')
        expect(user.full_name).to eq('Do not change')
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
      it { expect(subject.full_name).to eq('John Doe') }
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

  describe '.in_cassandra' do
    it do
      user = FactoryGirl.build(
        :user,
        id: '99a89669-557c-4c7a-a533-d1163caad65f')
      expect(CUser).to receive(:new)
        .with(id: '99a89669-557c-4c7a-a533-d1163caad65f')

      user.in_cassandra
    end
  end

  describe '.faves' do
    let(:user) do
      FactoryGirl.build(
        :user,
        id: '4f16d362-a336-4b12-a133-4b8e39be7f8e')
    end
    let(:c_user) { CUser.new(id: '4f16d362-a336-4b12-a133-4b8e39be7f8e') }
    let(:expectation) do
      instance_double('Cequel::Record::AssociationCollection')
    end

    before do
      expect(CUser).to receive(:new)
        .with(id: '4f16d362-a336-4b12-a133-4b8e39be7f8e')
        .and_return(c_user)
    end

    it 'calls CUserFave' do
      expect(c_user).to receive(:c_user_faves).and_return(expectation)

      expect(user.faves).to eq(expectation)
    end

    it 'is after last id' do
      set = instance_double('Cequel::Record::RecordSet')
      expect(c_user).to receive(:c_user_faves).and_return(set)
      expect(set).to receive(:before)
        .with(Cequel.uuid('9d6831a4-39d1-11e5-9128-17e501c711a8'))
        .and_return(expectation)

      expect(user.faves('9d6831a4-39d1-11e5-9128-17e501c711a8'))
        .to eq(expectation)
    end

    it 'is limited' do
      set = instance_double('Cequel::Record::RecordSet')
      expect(c_user).to receive(:c_user_faves).and_return(set)
      expect(set).to receive(:limit).with(5).and_return(expectation)

      expect(user.faves(nil, 5)).to eq(expectation)
    end
  end

  describe '.counter' do
    let(:user) do
      FactoryGirl.build(
        :user,
        id: '4f16d362-a336-4b12-a133-4b8e39be7f8e')
    end
    let(:c_user) do
      FactoryGirl.build(:c_user,
                        id: '4f16d362-a336-4b12-a133-4b8e39be7f8e')
    end
    let(:c_user_counter) do
      FactoryGirl.build(
        :c_user_counter,
        c_user: c_user,
        faves: 1,
        followers: 2,
        followings: 3)
    end

    context 'counter not set' do
      before do
        expect(CUserCounter).to receive(:find_or_initialize_by)
          .with(c_user_id: '4f16d362-a336-4b12-a133-4b8e39be7f8e')
          .and_return(c_user_counter)
      end

      it { expect(user.counter.faves).to eq(1) }
      it { expect(user.counter.followers).to eq(2) }
      it { expect(user.counter.followings).to eq(3) }
    end

    context 'counter already loaded' do
      before do
        user.instance_variable_set('@counter', c_user_counter)
        expect(CUserCounter).to_not receive(:find_or_initialize_by)
      end

      it { expect(user.counter.faves).to eq(1) }
      it { expect(user.counter.followers).to eq(2) }
      it { expect(user.counter.followings).to eq(3) }
    end
  end

  describe '.following?' do
    let(:user) do
      FactoryGirl.build(
        :user,
        id: '4f16d362-a336-4b12-a133-4b8e39be7f8e')
    end
    let(:target) do
      FactoryGirl.build(
        :user,
        id: '9d6831a4-39d1-11e5-9128-17e501c711a8')
    end
    let(:user_double) { instance_double('CUser') }
    let(:target_double) { instance_double('CUser') }

    before do
      allow(user).to receive(:in_cassandra).and_return(user_double)
      allow(target).to receive(:in_cassandra).and_return(target_double)
    end

    it do
      expect(user_double).to receive(:following?).with(target_double)
      user.following?(target)
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
end
