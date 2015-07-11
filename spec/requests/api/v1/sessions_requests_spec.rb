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
        .to receive(:fetch).and_raise(FbGraph2::Exception::InvalidToken, 'Invalid Token')
      get '/api/v1/sessions/facebook',
        nil,
        'X-Facebook-Token' => 'invalid-token'
    end

    it { expect(response.status).to eq(401) }
  end
end
