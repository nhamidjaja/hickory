# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Profile API', type: :request do
  before do
    FactoryGirl.create(
      :user,
      id: '4f16d362-a336-4b12-a133-4b8e39be7f8a',
      email: 'a@user.com',
      username: 'my_user',
      full_name: 'My User',
      description: 'My Description',
      profile_picture_url: 'http://abc.com/n.jpg',
      authentication_token: 'validtoken'
    )
  end

  describe 'authentication' do
    context 'unauthorized' do
      context 'no email' do
        before do
          get '/a/v1/me/profile',
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
          get '/a/v1/me/profile',
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
          get '/a/v1/me/profile',
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
          get '/a/v1/me/profile',
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
        it 'returns current user' do
          get '/a/v1/me/profile',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'

          expect(request.env['devise.skip_trackable']).to eq(true)
          expect(response.status).to eq(200)

          expect(json['user']['id'])
            .to eq('4f16d362-a336-4b12-a133-4b8e39be7f8a')
          expect(json['user']['username']).to eq('my_user')
          expect(json['user']['full_name']).to eq('My User')
          expect(json['user']['description']).to eq('My Description')
          expect(json['user']['profile_picture_url'])
            .to eq('http://abc.com/n.jpg')

          expect(json['user']['recent_faves']).to eq([])
          expect(json['user']['faves_count']).to eq(0)
          expect(json['user']['followers_count']).to eq(0)
          expect(json['user']['followings_count']).to eq(0)
        end
      end
    end
  end

  describe 'edit self profile' do
    context 'unauthenticated' do
      it 'is unauthorized' do
        post '/a/v1/me/profile',
             '{"user": {"username": "nicholas"}}',
             'Content-Type' => 'application/json'

        expect(response.status).to eq(401)
        expect(json['errors']).to_not be_blank
      end
    end

    context 'authenticated' do
      context 'valid' do
        it 'is successful' do
          post '/a/v1/me/profile',
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
          post '/a/v1/me/profile',
               '{"user": {"username": ""}}',
               'Content-Type' => 'application/json',
               'X-Email' => 'a@user.com',
               'X-Auth-Token' => 'validtoken'

          expect(response.status).to eq(422)
          expect(json['errors']['message']).to include('Username is invalid')
        end
      end
    end
  end
end
