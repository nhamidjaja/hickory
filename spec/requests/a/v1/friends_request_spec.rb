require 'rails_helper'

RSpec.describe 'Friends API', type: :request do
  describe 'authentication' do
    describe 'unauthorized' do
      before do
        FactoryGirl.create(:user,
                           email: 'a@user.com',
                           omniauth_token: 'validtoken')
      end

      context 'no email' do
        before do
          get '/a/v1/friends.json',
              nil,
              'X-Auth-Token' => 'validtoken'
        end

        it { expect(response.status).to eq(401) }
        it { expect(json['errors']).to_not be_blank }
      end

      context 'no token' do
        before do
          get '/a/v1/friends.json',
              nil,
              'X-Email' => 'a@user.com'
        end

        it { expect(response.status).to eq(401) }
      end

      context 'unregistered email' do
        before do
          get '/a/v1/friends.json',
              nil,
              'X-Email' => 'no@email.com',
              'X-Auth-Token' => 'atoken'
        end

        it { expect(response.status).to eq(401) }
      end

      context 'token different from saved' do
        before do
          get '/a/v1/friends.json',
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
                           authentication_token: 'validtoken')
      end

      let(:user2) do
        FactoryGirl.create(:user,
                           email: 'b@user.com',
                           username: 'userb',
                           provider: 'facebook',
                           authentication_token: 'validtokenb')
      end

      before { user }

      context 'get response' do
        it 'friends empty array' do
          get '/a/v1/friends.json',
              nil,
              'X-Email' => 'a@user.com', 'X-Auth-Token' => 'validtoken'

          expect(json['friends']).to eq([])
        end

        it 'friends not empty array' do
          FactoryGirl.create(:user_friend,
                             user_id: user.id,
                             provider: user2.provider,
                             uid: user2.uid)

          get '/a/v1/friends.json',
              nil,
              'X-Email' => 'a@user.com', 'X-Auth-Token' => 'validtoken'

          expect(json['friends']).to_not eq([])
          expect(json['friends'][0]['user_id']).to eq(user.id)
          expect(json['friends'][0]['uid']).to eq(user2.uid)
          expect(json['friends'][0]['username']).to eq(user2.username)
        end
      end
    end
  end
end
