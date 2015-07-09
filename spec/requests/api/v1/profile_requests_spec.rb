require 'rails_helper'

RSpec.describe 'Profile API', type: :request do
  describe 'authentication' do
    context 'no email' do
      before { get '/api/v1/profile.json' }
      it { expect(response.status).to eq(401) }
    end

    context 'no token' do
      before { get '/api/v1/profile.json' }
      it { expect(response.status).to eq(401) }
    end

    context 'unregistered email' do
      before do
        get '/api/v1/profile.json',
            nil,
            'X-Email' => 'no@email.com', 'X-Auth-Token' => 'atoken'
      end
      it { expect(response.status).to eq(401) }
    end
  end
end
