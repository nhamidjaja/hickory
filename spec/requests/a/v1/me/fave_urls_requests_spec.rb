require 'rails_helper'

RSpec.describe 'Fave Urls API', type: :request do
  describe 'get a url' do
    context 'unauthenticated' do
      it 'is unauthorized' do
        get '/a/v1/me/fave_urls?url=http://example.com'

        expect(response.status).to eq(401)
        expect(json['errors']).to_not be_blank
      end
    end

    context 'authorized' do
      before do
        FactoryGirl.create(
          :user,
          id: '4f16d362-a336-4b12-a133-4b8e39be7f8e',
          email: 'a@user.com',
          authentication_token: 'validtoken')
      end

      context 'url not faved' do
        it 'is not found' do
          get '/a/v1/me/fave_urls?url=http://example.com',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'

          expect(response.status).to eq(200)
          expect(json['fave_url']).to be_blank
        end
      end

      context 'url already faved' do
        before do
          FactoryGirl.create(
            :c_user_fave_url,
            c_user_id: '4f16d362-a336-4b12-a133-4b8e39be7f8e',
            content_url: 'http://example.com'
          )
        end

        it 'is successful' do
          get '/a/v1/me/fave_urls?url=http://example.com',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'

          expect(response.status).to eq(200)
          expect(json['fave_url']['content_url']).to eq('http://example.com')
          expect(json['fave_url']['faved_at']).to_not be_blank
          expect(json['fave_url']['faved_at']).to be_a(Fixnum)
        end
      end
    end
  end
end
