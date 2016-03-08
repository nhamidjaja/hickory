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

        allow(Typhoeus).to receive(:post)
      end

      context 'url not faved' do
        it 'is not found' do
          Sidekiq::Testing.inline! do
            expect_any_instance_of(CUserFave).to receive(:increment_view)

            get '/a/v1/me/fave_urls?url=http://example.com/not-faved'\
              '&faver_id=de305d54-75b4-431b-adb2-eb6b9e546014'\
              '&attribution_id=123e4567-e89b-12d3-a456-426655440000',
                nil,
                'X-Email' => 'a@user.com',
                'X-Auth-Token' => 'validtoken'

            expect(response.status).to eq(200)
            expect(json['fave_url']).to be_nil
          end
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
          Sidekiq::Testing.inline! do
            expect_any_instance_of(CUserFave).to receive(:increment_view)

            get '/a/v1/me/fave_urls?url=http://example.com'\
              '&faver_id=de305d54-75b4-431b-adb2-eb6b9e546014'\
              '&attribution_id=123e4567-e89b-12d3-a456-426655440000',
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

      context 'view own story' do
        it 'does not increment view counter' do
          Sidekiq::Testing.inline! do
            expect_any_instance_of(CUserFave).to_not receive(:increment_view)

            get '/a/v1/me/fave_urls?url=http://example.com/not-faved'\
              '&faver_id=4f16d362-a336-4b12-a133-4b8e39be7f8e'\
              '&attribution_id=123e4567-e89b-12d3-a456-426655440000',
                nil,
                'X-Email' => 'a@user.com',
                'X-Auth-Token' => 'validtoken'

            expect(response.status).to eq(200)
            expect(json['fave_url']).to be_nil
          end
        end
      end
    end
  end
end
