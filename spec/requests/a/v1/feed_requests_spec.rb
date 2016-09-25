# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Feed API', type: :request do
  let(:feeder) do
    FactoryGirl.create(
      :feeder,
      id: '123e4567-e89b-12d3-a456-426655440000'
    )
  end
  let(:user) do
    FactoryGirl.create(
      :user,
      id: 'de305d54-75b4-431b-adb2-eb6b9e546014',
      email: 'a@user.com',
      authentication_token: 'validtoken',
      feeders: [feeder]
    )
  end
  describe 'get list of feed entries' do
    context 'unauthenticated' do
      it 'is successful' do
        get '/a/v1/feed'

        expect(response.status).to eq(200)
        expect(json['entries']).to be_empty
      end
    end

    context 'authenticated' do
      before { user }

      context 'no entry' do
        it 'is successful' do
          get '/a/v1/feed',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'

          expect(response.status).to eq(200)
          expect(json['entries']).to be_empty
        end
      end

      context 'one entry' do
        let(:entry) do
          FactoryGirl.create(:top_article,
                             published_at: '2015-07-20 19:01:10 +03:00',
                             feeder: feeder)
        end

        before { entry }

        it 'is successful' do
          get '/a/v1/feed',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'

          expect(response.status).to eq(200)
          expect(json['entries'].size).to eq(1)

          article = json['entries'].first
          expect(article['title']).to_not be_blank
          expect(article['content_url']).to_not be_blank
          expect(article['image_url']).to_not be_blank
          expect(article['published_at']).to eq(1_437_408_070)
        end
      end

      context 'many entries' do
        before do
          entries = FactoryGirl.build_list(:top_article, 31)
          feeder.top_articles << entries
        end

        it 'is limited to 30' do
          get '/a/v1/feed',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'

          expect(response.status).to eq(200)
          expect(json['entries'].size).to eq(30)
        end

        describe 'paginated' do
          # TODO: can be improved
          it 'is successful' do
            FactoryGirl.create(
              :top_article,
              feeder: feeder,
              published_at: '2015-07-29 15:30:00 +07:00'
            )

            get '/a/v1/feed?last_published_at=1438176600',
                nil,
                'X-Email' => 'a@user.com',
                'X-Auth-Token' => 'validtoken'

            expect(response.status).to eq(200)

            expect(json['entries'].size).to eq(1)
          end
        end
      end
    end
  end
end
