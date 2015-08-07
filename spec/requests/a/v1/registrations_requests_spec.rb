require 'rails_helper'

RSpec.describe 'User Registrations API', type: :request do
  describe 'register through facebook' do
    context 'no token' do
      it 'is unauthorized' do
        post '/a/v1/registrations/facebook'

        expect(response.status).to eq(401)
        expect(json['errors']['message'])
          .to match('No Facebook token provided')
      end
    end

    context 'with invalid token' do
      before do
        expect_any_instance_of(FbGraph2::User)
          .to receive(:fetch)
          .and_raise(FbGraph2::Exception::InvalidToken, 'Invalid token')
      end

      it 'is unauthorized' do
        post '/a/v1/registrations/facebook',
             nil,
             'X-Facebook-Token' => 'invalid-token'

        expect(response.status).to eq(401)
        expect(json['errors']['message']).to match('Invalid token')
      end
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

      context 'valid user' do
        it 'creates user' do
          post '/a/v1/registrations/facebook',
               '{"user": {"username": "nicholas"}}',
               'Content-Type' => 'application/json',
               'X-Facebook-Token' => 'fb-token'

          expect(response.status).to eq(201)
          expect(json['user']['email']).to match('new@email.com')
          expect(json['user']['username']).to match('nicholas')
          expect(json['user']['authentication_token']).to_not be_blank
        end
      end

      context 'invalid user' do
        it 'is unprocessable entity' do
          post '/a/v1/registrations/facebook',
               '{"user": {"username": ""}}',
               'Content-Type' => 'application/json',
               'X-Facebook-Token' => 'fb-token'

          expect(response.status).to eq(422)
          expect(json['user']['errors']['username']).to eq(['is invalid'])
        end
      end
    end
  end
end
