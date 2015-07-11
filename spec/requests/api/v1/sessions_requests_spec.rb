require 'rails_helper'

RSpec.describe 'sessions', type: :request do
  context 'no token' do
    before do
      get '/api/v1/sessions/facebook'
    end

    it { expect(response.status).to eq(401) }
  end

  context 'with invalid token' do
    before do
      expect_any_instance_of(FbGraph2::User)
        .to receive(:fetch)
        .and_raise(FbGraph2::Exception::InvalidToken, 'Invalid Token')
      get '/api/v1/sessions/facebook',
          nil,
          'X-Facebook-Token' => 'invalid-token'
    end

    it { expect(response.status).to eq(401) }
  end

  context 'valid token' do
    context 'new user' do
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

        get '/api/v1/sessions/facebook',
            nil,
            'X-Facebook-Token' => 'fb-token'
      end

      it { expect(response.status).to eq(404) }
      it { expect(json['errors']['message']).to match(/Unregistered user/) }
    end

    context 'existing email' do
      before do
        FactoryGirl.create(:user, email: 'existing@email.com')
        double = instance_double(
          'FbGraph2::User',
          email: 'existing@email.com',
          id: 'x123',
          access_token: 'fb-token'
          )

        expect_any_instance_of(FbGraph2::User)
          .to receive(:fetch)
          .and_return(double)
      end

      context 'success' do
        before do
          get '/api/v1/sessions/facebook',
              nil,
              'X-Facebook-Token' => 'fb-token'
        end
        
        it { expect(response.status).to eq(200) }
        it { expect(json['user']['email']).to match('existing@email.com') }
      end

      context 'fail to save' do
        before do
          expect_any_instance_of(User)
            .to receive(:save!)
            .and_raise(StandardError, 'Failed to save')

          get '/api/v1/sessions/facebook',
              nil,
              'X-Facebook-Token' => 'fb-token'
        end
        
        it { expect(response.status).to eq(500) }
        it { expect(json['errors']['message']).to_not be_blank }
      end
    end
  end
end
