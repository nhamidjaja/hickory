require 'rails_helper'

RSpec.describe 'Profile API', type: :request do
  describe 'authentication' do
    describe 'unauthorized' do
      before do
        FactoryGirl.create(:user,
                           email: 'a@user.com',
                           omniauth_token: 'validtoken')
      end

      context 'no email' do
        before do
          get '/api/v1/profile.json',
              nil,
              'X-Auth-Token' => 'validtoken'
        end

        it { expect(response.status).to eq(401) }
      end

      context 'no token' do
        before do
          get '/api/v1/profile.json',
              nil,
              'X-Email' => 'a@user.com'
        end

        it { expect(response.status).to eq(401) }
      end

      context 'unregistered email' do
        before do
          get '/api/v1/profile.json',
              nil,
              'X-Email' => 'no@email.com',
              'X-Auth-Token' => 'atoken'
        end

        it { expect(response.status).to eq(401) }
      end

      context 'token different from saved' do
        before do
          double = instance_double('FbGraph2::User', access_token: 'alsovalid')
          allow(double).to receive(:fetch)
            .and_raise(FbGraph2::Exception::InvalidToken, 'invalid token')

          allow(FbGraph2::User).to receive(:me).and_return(double)

          get '/api/v1/profile.json',
              nil,
              'X-Email' => 'a@user.com', 'X-Auth-Token' => 'atoken'
        end

        it { expect(response.status).to eq(401) }
      end
    end

    describe 'authorized' do
      let(:user) do
        FactoryGirl.create(:user,
                           email: 'a@user.com',
                           username: 'my_user',
                           omniauth_token: 'validtoken')
      end
      before { user }

      context 'token already saved' do
        before do
          get '/api/v1/profile.json',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'
        end

        it { expect(response.status).to eq(200) }

        it { expect(json['user']['id']).to_not be_blank }
        it { expect(json['user']['email']).to eq('a@user.com') }
        it { expect(json['user']['username']).to eq('my_user') }
      end

      context 'different but valid third-party token' do
        before do
          fb_user = instance_double('FbGraph2::User', access_token: 'alsovalid')
          expect_any_instance_of(FbGraph2::User)
            .to receive(:fetch).and_return(fb_user)

          get '/api/v1/profile.json',
              nil,
              'X-Email' => 'a@user.com', 'X-Auth-Token' => 'alsovalid'
        end

        it { expect(response.status).to eq(200) }
        it do
          user.reload
          expect(user.omniauth_token).to eq('alsovalid')
        end
      end
    end
  end
end
