# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'GCM API', type: :request do
  describe 'new token registration' do
    context 'unauthenticated' do
      it 'is succesful' do
        expect do
          post '/a/v1/me/gcm',
               '{"gcm": {"registration_token": "anonymou5"}}',
               'Content-Type' => 'application/json'
        end.to change { Gcm.count }.by(1)

        expect(response.status).to eq(200)
        expect(json['gcm']['user_id']).to be_nil
        expect(json['gcm']['registration_token']).to eq('anonymou5')
      end

      context 'invalid' do
        it 'is unprocessable entity' do
          expect do
            post '/a/v1/me/gcm',
                 '{"gcm": {"registration_token": ""}}',
                 'Content-Type' => 'application/json'
          end.to_not change { Gcm.count }

          expect(response.status).to eq(422)
        end
      end
    end

    context 'authenticated' do
      before do
        FactoryGirl.create(
          :user,
          id: '4f16d362-a336-4b12-a133-4b8e39be7f8a',
          email: 'a@user.com',
          authentication_token: 'validtoken'
        )
      end

      it 'is succesful' do
        expect do
          post '/a/v1/me/gcm',
               '{"gcm": {"registration_token": "auser"}}',
               'Content-Type' => 'application/json',
               'X-Email' => 'a@user.com',
               'X-Auth-Token' => 'validtoken'
        end.to change { Gcm.count }.by(1)

        expect(response.status).to eq(200)
        expect(json['gcm']['user_id'])
          .to eq('4f16d362-a336-4b12-a133-4b8e39be7f8a')
        expect(json['gcm']['registration_token']).to eq('auser')
      end
    end
  end

  describe 'update an existing token' do
    before { FactoryGirl.create(:gcm, registration_token: 'auser') }

    context 'authenticated' do
      before do
        FactoryGirl.create(
          :user,
          id: '4f16d362-a336-4b12-a133-4b8e39be7f8a',
          email: 'a@user.com',
          authentication_token: 'validtoken'
        )
      end

      it 'is succesful' do
        expect do
          post '/a/v1/me/gcm',
               '{"gcm": {"registration_token": "auser"}}',
               'Content-Type' => 'application/json',
               'X-Email' => 'a@user.com',
               'X-Auth-Token' => 'validtoken'
        end.to_not change { Gcm.count }

        expect(response.status).to eq(200)
        expect(json['gcm']['user_id'])
          .to eq('4f16d362-a336-4b12-a133-4b8e39be7f8a')
        expect(json['gcm']['registration_token']).to eq('auser')
      end
    end
  end
end
