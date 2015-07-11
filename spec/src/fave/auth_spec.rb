require 'rails_helper'

RSpec.describe Fave::Auth do
  describe '#new' do
    subject { Fave::Auth.new('some@email.com', 'oauth', 'x123', 'token') }

    it { is_expected.to respond_to(:email) }
    it { is_expected.to respond_to(:uid) }
    it { is_expected.to respond_to(:provider) }
    it { is_expected.to respond_to(:token) }

    it { expect(subject.email).to eq('some@email.com') }
    it { expect(subject.provider).to eq('oauth') }
    it { expect(subject.uid).to eq('x123') }
    it { expect(subject.token).to eq('token') }
  end

  describe '#from_omniauth' do
    let(:callback) do
      { 'provider' => 'facebook', 'uid' => 'x123',
        'info' => { 'email' => 'a@b.com' },
        'credentials' => { 'token' => 'abc098' } }
    end

    subject { Fave::Auth.from_omniauth(callback) }

    it { expect(subject.email).to eq('a@b.com') }
    it { expect(subject.provider).to eq('facebook') }
    it { expect(subject.uid).to eq('x123') }
    it { expect(subject.token).to eq('abc098') }
  end

  describe '#from_facebook' do
    let(:fb_user) do
      instance_double('FbGraph2::User', email: 'a@b.com', id: 'x123', access_token: 'abc098' )
    end

    subject { Fave::Auth.from_facebook(fb_user) }

    it { expect(subject.email).to eq('a@b.com') }
    it { expect(subject.provider).to eq('facebook') }
    it { expect(subject.uid).to eq('x123') }
    it { expect(subject.token).to eq('abc098') }
  end
end
