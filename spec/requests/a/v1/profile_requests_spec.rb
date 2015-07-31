require 'rails_helper'

RSpec.describe 'Profile API', type: :request do
  describe 'authentication' do
    context 'unauthorized' do
      before do
        FactoryGirl.create(:user,
                           email: 'a@user.com',
                           omniauth_token: 'validtoken')
      end

      context 'no email' do
        before do
          get '/a/v1/profile.json',
              nil,
              'X-Auth-Token' => 'validtoken'
        end

        it 'is unauthorized' do
          expect(response.status).to eq(401)
          expect(json['errors']).to_not be_blank
        end
      end

      context 'no token' do
        before do
          get '/a/v1/profile.json',
              nil,
              'X-Email' => 'a@user.com'
        end

        it 'is unauthorized' do
          expect(response.status).to eq(401)
          expect(json['errors']).to_not be_blank
        end
      end

      context 'unregistered email' do
        before do
          get '/a/v1/profile.json',
              nil,
              'X-Email' => 'no@email.com',
              'X-Auth-Token' => 'atoken'
        end

        it 'is unauthorized' do
          expect(response.status).to eq(401)
          expect(json['errors']).to_not be_blank
        end
      end

      context 'token different from saved' do
        before do
          get '/a/v1/profile.json',
              nil,
              'X-Email' => 'a@user.com', 'X-Auth-Token' => 'atoken'
        end

        it 'is unauthorized' do
          expect(response.status).to eq(401)
          expect(json['errors']).to_not be_blank
        end
      end
    end

    context 'authorized' do
      before do
        FactoryGirl.create(:user,
                           email: 'a@user.com',
                           username: 'my_user',
                           authentication_token: 'validtoken')
      end

      context 'token already saved' do
        before do
          get '/a/v1/profile.json',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'
        end

        it 'returns current user' do
          expect(request.env['devise.skip_trackable']).to eq(true)
          expect(response.status).to eq(200)

          expect(json['user']['id']).to_not be_blank
          expect(json['user']['email']).to eq('a@user.com')
          expect(json['user']['username']).to eq('my_user')
        end
      end

      context 'edit my profile' do
        it 'update username without parameter' do
          get '/a/v1/profile/update',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'

          expect(response.status).to eq(404)
        end

        it 'update username with not exist username' do
          get '/a/v1/profile/update?username=bebek',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'

          expect(json['user']['username']).to eq('bebek')
        end

        it 'update username with exist username' do
          FactoryGirl.create(:user,
                           email: 'ab@user.com',
                           username: 'user',
                           authentication_token: 'validtokenbcd')

          get '/a/v1/profile/update?username=user',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'

          expect(response.status).to eq(404)
        end
      end
    end
  end
end
