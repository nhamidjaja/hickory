require 'rails_helper'

RSpec.describe 'Top Articles API', type: :request do
  context 'authorized' do
    before do
      FactoryGirl.create(:user,
                         email: 'a@user.com',
                         username: 'my_user',
                         authentication_token: 'validtoken')
    end

    context 'without parameters' do
      subject do
        get '/a/v1/top_articles',
            nil
      end

      context 'no articles' do
        it 'is successful and empty' do
          subject

          expect(response.status).to eq(200)
          expect(json['top_articles']).to eq([])
        end
      end

      context 'one article' do
        before do
          feeder = FactoryGirl.create(:feeder)
          FactoryGirl.create(:top_article,
                             feeder: feeder,
                             published_at: '2015-07-20 19:01:10 +03:00')
        end

        it 'has article' do
          subject

          expect(response.status).to eq(200)
          expect(json['top_articles'].size).to eq(1)

          article = json['top_articles'].first
          expect(article['title']).to_not be_blank
          expect(article['content_url']).to_not be_blank
          expect(article['image_url']).to_not be_blank
          expect(article['published_at']).to eq(1_437_408_070)
        end
      end

      context 'many articles' do
        it 'is limited to 50' do
          feeder = FactoryGirl.create(:feeder)
          51.times do
            FactoryGirl.create(:top_article, feeder: feeder)
          end

          subject

          expect(response.status).to eq(200)
          expect(json['top_articles'].size).to eq(50)
        end

        it 'is sorted by descending published_at' do
          feeder = FactoryGirl.create(:feeder)

          FactoryGirl.create(:top_article,
                             feeder: feeder,
                             published_at: '2015-07-29 15:30:00 +07:00')
          FactoryGirl.create(:top_article,
                             feeder: feeder,
                             published_at: '2015-07-29 20:30:00 +07:00')

          subject

          expect(response.status).to eq(200)
          expect(json['top_articles'][0]['published_at']).to eq(1_438_176_600)
          expect(json['top_articles'][1]['published_at']).to eq(1_438_158_600)
        end
      end
    end

    context 'with last_published_at' do
      it 'filter older than last published data' do
        feeder = FactoryGirl.create(:feeder)

        FactoryGirl.create(:top_article,
                           feeder: feeder,
                           published_at: '2015-07-29 15:30:00 +07:00')
        # 1438158600 => '2015-07-29 15:30:00 +07:00'
        FactoryGirl.create(:top_article,
                           feeder: feeder,
                           published_at: '2015-07-29 20:30:00 +07:00')
        # 1438176600 => '2015-07-29 20:30:00 +07:00'

        get '/a/v1/top_articles?last_published_at=1438176600',
            nil

        expect(response.status).to eq(200)

        expect(json['top_articles'].size).to eq(1)
        expect(json['top_articles'][0]['published_at']).to eq(1_438_158_600)
      end
    end
  end
end
