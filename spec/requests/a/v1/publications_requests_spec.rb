# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Publications API', type: :request do
  let(:user) do
    FactoryGirl.create(
      :user,
      id: 'de305d54-75b4-431b-adb2-eb6b9e546014',
      email: 'a@user.com',
      authentication_token: 'validtoken'
    )
  end
  let(:feeder) do
    FactoryGirl.create(
      :feeder,
      id: '123e4567-e89b-12d3-a456-426655440000'
    )
  end

  describe 'get list of publications' do
    context 'no publications' do
      it 'is successful' do
        get '/a/v1/publications'

        expect(response.status).to eq(200)
        expect(json['publications']).to be_empty
      end
    end

    context 'one publication' do
      before do
        FactoryGirl.create(
          :feeder,
          id: 'f1ac29af-813e-4769-aaea-a0c697bbaa17',
          feed_url: 'http://example.com/rss'
        )
      end

      it 'is successful' do
        get '/a/v1/publications'

        expect(response.status).to eq(200)
        expect(json['publications'].size).to eq(1)

        publication = json['publications'].first
        expect(publication['id']).to eq('f1ac29af-813e-4769-aaea-a0c697bbaa17')
        expect(publication['feed_url']).to eq('http://example.com/rss')
        expect(publication['title']).to_not be_empty
        expect(publication['description']).to_not be_empty
      end
    end

    context 'many publications' do
      before { FactoryGirl.create_list(:feeder, 31) }

      it 'is limited to 30' do
        get '/a/v1/publications'

        expect(response.status).to eq(200)
        expect(json['publications'].size).to eq(30)
      end

      it 'is offset' do
        get '/a/v1/publications?offset=25'

        expect(response.status).to eq(200)
        expect(json['publications'].size).to eq(6)
      end
    end
  end

  describe 'get list of featured publications' do
    context 'authenticated' do
      before { user }

      context 'no publications' do
        it 'is successful' do
          get '/a/v1/publications/featured',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'

          expect(response.status).to eq(200)
          expect(json['publications']).to be_empty
        end
      end
    end
  end

  describe 'get a publication' do
    before do
      FactoryGirl.create(
        :feeder,
        id: '4f16d362-a336-4b12-a133-4b8e39be7f8e'
      )
    end

    context 'does not exist' do
      it 'is not found' do
        get '/a/v1/publications/id-not-in-system'

        expect(response.status).to eq(404)
        expect(json['errors']).to_not be_blank
      end
    end

    context 'exists' do
      it 'is successful' do
        get '/a/v1/publications/4f16d362-a336-4b12-a133-4b8e39be7f8e'

        expect(response.status).to eq(200)

        expect(json['publication']['id']).to eq(
          '4f16d362-a336-4b12-a133-4b8e39be7f8e'
        )
        expect(json['publication']['feed_url']).to_not be_empty
        expect(json['publication']['title']).to_not be_empty
        expect(json['publication']['description']).to_not be_empty
      end
    end
  end

  describe 'subscribe to a publication' do
    context 'unauthenticated' do
      it 'is unauthorized' do
        get '/a/v1/publications/99a89669-557c-4c7a-a533-d1163caad65f'\
            '/subscribe'

        expect(response.status).to eq(401)
        expect(json['errors']).to_not be_blank
      end
    end

    context 'authenticated' do
      before do
        user
        feeder
      end

      context 'non-existing' do
        it 'is not found' do
          get '/a/v1/publications/id-not-found/subscribe',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'

          expect(response.status).to eq(404)
          expect(json['errors']).to_not be_blank
        end
      end

      context 'exists' do
        it 'is successful' do
          expect do
            get '/a/v1/publications/123e4567-e89b-12d3-a456-426655440000'\
                '/subscribe',
                nil,
                'X-Email' => 'a@user.com',
                'X-Auth-Token' => 'validtoken'
          end.to change { FeedersUser.count }.by(1)

          expect(response.status).to eq(200)
        end
      end
    end
  end

  describe 'unsubscribe from a publication' do
    context 'unauthenticated' do
      it 'is unauthorized' do
        get '/a/v1/publications/99a89669-557c-4c7a-a533-d1163caad65f'\
            '/unsubscribe'

        expect(response.status).to eq(401)
        expect(json['errors']).to_not be_blank
      end
    end

    context 'authenticated' do
      before do
        user.feeders << feeder
      end

      context 'non-existing' do
        it 'is not found' do
          get '/a/v1/publications/id-not-found/unsubscribe',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'

          expect(response.status).to eq(404)
          expect(json['errors']).to_not be_blank
        end
      end

      context 'exists' do
        it 'is successful' do
          expect do
            get '/a/v1/publications/123e4567-e89b-12d3-a456-426655440000'\
                '/unsubscribe',
                nil,
                'X-Email' => 'a@user.com',
                'X-Auth-Token' => 'validtoken'
          end.to change { FeedersUser.count }.by(-1)

          expect(response.status).to eq(200)
        end
      end
    end
  end
end
