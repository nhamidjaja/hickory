require 'rails_helper'

RSpec.describe Fave::Auth do
  describe '#new' do
    subject do
      Fave::Auth.new(
        'some@email.com',
        'oauth',
        'x123',
        'token',
        'John Doe',
        'http://example.com/pic.jpg'
      )
    end

    it { is_expected.to respond_to(:email) }
    it { is_expected.to respond_to(:uid) }
    it { is_expected.to respond_to(:provider) }
    it { is_expected.to respond_to(:token) }
    it { is_expected.to respond_to(:full_name) }
    it { is_expected.to respond_to(:picture) }

    it { expect(subject.email).to eq('some@email.com') }
    it { expect(subject.provider).to eq('oauth') }
    it { expect(subject.uid).to eq('x123') }
    it { expect(subject.token).to eq('token') }
    it { expect(subject.full_name).to eq('John Doe') }
    it { expect(subject.picture).to eq('http://example.com/pic.jpg') }
  end

  describe '#from_omniauth' do
    let(:callback) do
      { 'provider' => 'facebook', 'uid' => 'x123',
        'info' => { 'email' => 'a@b.com',
                    'name' => 'John Doe',
                    'image' => 'http://pic.com/n.jpg' },
        'credentials' => { 'token' => 'abc098' } }
    end

    subject { Fave::Auth.from_omniauth(callback) }

    it { expect(subject.email).to eq('a@b.com') }
    it { expect(subject.provider).to eq('facebook') }
    it { expect(subject.uid).to eq('x123') }
    it { expect(subject.token).to eq('abc098') }
    it { expect(subject.full_name).to eq('John Doe') }
    it { expect(subject.picture).to eq('http://pic.com/n.jpg') }
  end

  describe '#from_koala' do
    let(:koala_user) do
      { 'id' => 'x123',
        'email' => 'a@b.com',
        'name' => 'Jane Doe',
        'picture' =>
        { 'data' =>
          {
            'url' => 'http://abc.com/123.jpg'
          } } }
    end

    subject { Fave::Auth.from_koala(koala_user, 'abc098') }

    it { expect(subject.email).to eq('a@b.com') }
    it { expect(subject.provider).to eq('facebook') }
    it { expect(subject.uid).to eq('x123') }
    it { expect(subject.token).to eq('abc098') }
    it { expect(subject.full_name).to eq('Jane Doe') }
    it { expect(subject.picture).to eq('http://abc.com/123.jpg') }
  end
end
