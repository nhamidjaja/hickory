require 'rails_helper'

RSpec.describe 'Search API', type: :request do
  describe 'authentication' do
    describe 'unauthorized' do
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
    end

    describe 'authorized' do
      before do
        FactoryGirl.create(:user,
                           email: 'a@user.com',
                           username: 'my_user',
                           authentication_token: 'validtoken')
      end

      context 'search user saved' do
        before do
          get '/a/v1/search/my_user',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'
        end

        it 'returns user by username' do
          expect(response.status).to eq(200)
        end
      end
    end
  end
end
