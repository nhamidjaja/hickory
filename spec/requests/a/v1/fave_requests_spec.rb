require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe 'Fave API', type: :request do
  context 'unauthenticated' do
    it 'is unauthorized' do
      get '/a/v1/fave'

      expect(response.status).to eq(401)
      expect(json['errors']).to_not be_blank
    end
  end

  context 'authorized' do
    before do
      FactoryGirl.create(
        :user,
        id: 'de305d54-75b4-431b-adb2-eb6b9e546014',
        email: 'a@user.com',
        username: 'user',
        authentication_token: 'validtoken'
      )
    end

    it 'saves CUserFave' do
      Sidekiq::Testing.inline! do
        expect do
          get '/a/v1/fave?url=http://example.com/hello?source=xyz',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'
        end.to change(CUserFave, :count).by(1)

        expect(CUserCounter['de305d54-75b4-431b-adb2-eb6b9e546014'].faves)
          .to eq(1)

        expect(response.status).to eq(200)
      end
    end
  end
end
