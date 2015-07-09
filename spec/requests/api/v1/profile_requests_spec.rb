require 'rails_helper'

RSpec.describe 'Profile API', type: :request do
  describe 'authentication' do
    describe 'unauthorized' do
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

      context 'token different from saved' do
        let(:user) { FactoryGirl.create(:user, email: 'a@user.com', omniauth_token: 'validtoken') }
        before do
          user

          get '/api/v1/profile.json',
              nil,
              'X-Email' => 'a@user.com', 'X-Auth-Token' => 'atoken'
        end

        it { expect(response.status).to eq(401) }
      end
    end

    describe 'authorized' do
      let(:user) { FactoryGirl.create(:user, email: 'a@user.com', omniauth_token: 'validtoken') }
      before { user }

      context 'token already saved' do
        before do
          get '/api/v1/profile.json',
              nil,
              'X-Email' => 'a@user.com', 'X-Auth-Token' => 'validtoken'
        end

        it { expect(response.status).to eq(200) }
      end
    end
  end
end
