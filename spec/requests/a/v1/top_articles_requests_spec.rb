require 'rails_helper'

RSpec.describe 'Top Articles API', type: :request do
  describe 'authentication' do
    describe 'unauthorized' do
      before do
        FactoryGirl.create(:user,
                           email: 'a@user.com',
                           omniauth_token: 'validtoken')
      end

      context 'no email' do
        before do
          get '/a/v1/top_articles',
              nil,
              'X-Auth-Token' => 'validtoken'
        end

        it { expect(response.status).to eq(401) }
        it { expect(json['errors']).to_not be_blank }
      end

      context 'no token' do
        before do
          get '/a/v1/top_articles',
              nil,
              'X-Email' => 'a@user.com'
        end

        it { expect(response.status).to eq(401) }
      end

      context 'unregistered email' do
        before do
          get '/a/v1/top_articles',
              nil,
              'X-Email' => 'no@email.com',
              'X-Auth-Token' => 'atoken'
        end

        it { expect(response.status).to eq(401) }
      end

      context 'token different from saved' do
        before do
          get '/a/v1/top_articles',
              nil,
              'X-Email' => 'a@user.com', 'X-Auth-Token' => 'atoken'
        end

        it { expect(response.status).to eq(401) }
      end
    end

    describe 'authorized' do
      let(:top_article) { FactoryGirl.create(:top_article) }

      before do
        FactoryGirl.create(:user,
                           email: 'a@user.com',
                           username: 'my_user',
                           authentication_token: 'validtoken')
      end

      subject do
        get '/a/v1/top_articles',
            nil,
            'X-Email' => 'a@user.com',
            'X-Auth-Token' => 'validtoken'
      end

      context 'token valid' do
        it 'response code 200 and return []' do
          subject

          expect(response.status).to eq(200)
          expect(json['top_articles']).to eq([])
        end
      end

      context 'view response' do
        it 'return 1 data' do
          top_article
          subject

          expect(json['top_articles']).to_not eq([])
          expect(json['top_articles'][0]['title']).to eq(top_article.title)
          expect(json['top_articles'][0]['content_url']
                ).to eq(top_article.content_url)
        end

        it 'return all data sort desc' do
          top_article

          feed = FactoryGirl.create(:feeder, feed_url: 'http://detik.com/feed.rss')
          top_article2 = FactoryGirl.create(:top_article,
                                            feeder: feed, title: 'articledetik',
                                            published_at: Time.zone.now)

          subject

          expect(json['top_articles']).to_not eq([])
          expect(json['top_articles'][0]['title']).to eq(top_article2.title)
          expect(json['top_articles'][0]['content_url']
                ).to eq(top_article2.content_url)
          expect(json['top_articles'][1]['title']).to eq(top_article.title)
          expect(json['top_articles'][1]['content_url']
                ).to eq(top_article.content_url)
        end
      end

      context 'with limit' do
        before do
          feed = FactoryGirl.create(:feeder, feed_url: 'http://detik.com/feed.rss')
          FactoryGirl.create(:top_article,
                             feeder: feed, title: 'articledetik',
                             published_at: Time.zone.now)
        end

        it 'return 1 data' do
          top_article

          get '/a/v1/top_articles?limit=1',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'

          expect(json['top_articles'].size).to eq(1)
        end

        it 'return 2 data' do
          top_article

          get '/a/v1/top_articles?limit=2',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'

          expect(json['top_articles'].size).to eq(2)
        end
      end

      context 'with last_published_at' do
        before do
          feed = FactoryGirl.create(:feeder, feed_url: 'http://detik.com/feed.rss')
          FactoryGirl.create(:top_article,
                             feeder: feed, title: 'articledetik')
        end

        it 'return 0 data' do
          get '/a/v1/top_articles?limit=2&last_published_at=1420045200',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'

          expect(json['top_articles'].size).to eq(0)
        end

        it 'return 2 data' do
          top_article

          get '/a/v1/top_articles?limit=2&last_published_at=1437418870',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'

          expect(json['top_articles'].size).to eq(2)
        end
      end
    end
  end
end
