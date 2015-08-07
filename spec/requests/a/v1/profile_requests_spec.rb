require 'rails_helper'

RSpec.describe 'Profile API', type: :request do
  before do
    FactoryGirl.create(:user,
                       email: 'a@user.com',
                       username: 'my_user',
                       full_name: 'My User',
                       description: 'My Description',
                       authentication_token: 'validtoken')
  end

  describe 'authentication' do
    context 'unauthorized' do
      context 'no email' do
        before do
          get '/a/v1/profile',
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
          get '/a/v1/profile',
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
          get '/a/v1/profile',
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
          get '/a/v1/profile',
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
      context 'token already saved' do
        before do
          get '/a/v1/profile',
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
          expect(json['user']['full_name']).to eq('My User')
          expect(json['user']['description']).to eq('My Description')
        end
      end
    end
  end

  describe 'edit self profile' do
    context 'unauthenticated' do
      it 'is unauthorized' do
        post '/a/v1/profile',
             '{"user": {"username": "nicholas"}}',
             'Content-Type' => 'application/json'

        expect(response.status).to eq(401)
        expect(json['errors']).to_not be_blank
      end
    end

    context 'authenticated' do
      context 'valid' do
        it 'is successful' do
          post '/a/v1/profile',
               '{"user": {"username": "nicholas",
               "full_name": "Read Flyer",
               "description": "Description Flyer"}}',
               'Content-Type' => 'application/json',
               'X-Email' => 'a@user.com',
               'X-Auth-Token' => 'validtoken'

          expect(response.status).to eq(200)
          expect(json['user']['username']).to match('nicholas')
          expect(json['user']['full_name']).to match('Read Flyer')
          expect(json['user']['description']).to match('Description Flyer')
        end
      end

      context 'invalid' do
        it 'is unprocessable entity' do
          post '/a/v1/profile',
               '{"user": {"username": ""}}',
               'Content-Type' => 'application/json',
               'X-Email' => 'a@user.com',
               'X-Auth-Token' => 'validtoken'

          expect(response.status).to eq(422)
          expect(json['user']['errors']['username']).to match(['is invalid'])
        end
      end
    end
  end
end
