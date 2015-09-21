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
    let(:user) do
      FactoryGirl.create(
        :user,
        id: 'de305d54-75b4-431b-adb2-eb6b9e546014',
        email: 'a@user.com',
        username: 'user',
        authentication_token: 'validtoken'
      )
    end

    before do
      3.times do
        FactoryGirl.create(:follower,
                           c_user: user.in_cassandra
                          )
      end
    end

    it 'is successful' do
      Sidekiq::Testing.inline! do
        expect(Story.count).to eq(0)
        expect(user.in_cassandra.followers.count).to eq(3)

        expect do
          get '/a/v1/fave?url=http://example.com/hello?source=xyz',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'
        end.to change(CUserFave, :count).by(1)

        expect(response.status).to eq(200)

        expect(CUserCounter['de305d54-75b4-431b-adb2-eb6b9e546014'].faves)
          .to eq(1)
        expect(Story.count).to eq(3)
      end
    end
  end
end
