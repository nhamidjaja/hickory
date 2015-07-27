require 'rails_helper'

RSpec.describe 'Top Articles API', type: :request do
    context 'unsigned in user' do
      before { get '/a/v1/top_articles' }

      it { expect(response.status).to eq(401) }
      it { expect(json['errors']).to_not be_blank }
    end

    context 'signed in user' do
      # stub authentication
      sign_in_as_user

      let(:top_article) { FactoryGirl.create(:top_article) }

      subject { get '/a/v1/top_articles' }

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
