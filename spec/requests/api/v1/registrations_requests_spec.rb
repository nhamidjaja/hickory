require 'rails_helper'

RSpec.describe 'User Registrations API', type: :request do
  context 'no token' do
    before do
      post '/api/v1/registrations/facebook'
    end

    it { expect(response.status).to eq(401) }
    it do
      expect(json['errors']['message'])
        .to match('No Facebook token provided')
    end
  end

  context 'with invalid token' do
    before do
      expect_any_instance_of(FbGraph2::User)
        .to receive(:fetch)
        .and_raise(FbGraph2::Exception::InvalidToken, 'Invalid token')
      post '/api/v1/registrations/facebook',
          nil,
          'X-Facebook-Token' => 'invalid-token'
    end

    it { expect(response.status).to eq(401) }
    it { expect(json['errors']['message']).to match('Invalid token') }
  end

  context 'valid token' do
    before do
      double = instance_double(
        'FbGraph2::User',
        email: 'new@email.com',
        id: 'x123',
        access_token: 'fb-token'
      )

      expect_any_instance_of(FbGraph2::User)
        .to receive(:fetch)
        .and_return(double)
    end

    context 'create new user' do
      before do
        post '/api/v1/registrations/facebook',
            '{"user": {"username": "nicholas"}}',
            'Content-Type' => 'application/json',
            'X-Facebook-Token' => 'fb-token'
      end

      it { expect(response.status).to eq(201) }
      it { expect(json['user']['email']).to match('new@email.com') }
      it { expect(json['user']['username']).to match('nicholas') }
      it { expect(json['user']['authentication_token']).to_not be_blank }
    end

    context 'invalid user without username' do
      before do
        post '/api/v1/registrations/facebook',
            '{"user": {"username": ""}}',
            'Content-Type' => 'application/json',
            'X-Facebook-Token' => 'fb-token'
      end

      it { expect(response.status).to eq(400) }
      it { expect(json['errors']['username']).to eq(['is invalid']) }
    end
  end
end
