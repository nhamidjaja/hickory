require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  context 'unauthenticated' do
    it 'is unauthorized' do
      get '/a/v1/users/99a89669-557c-4c7a-a533-d1163caad65f'

      expect(response.status).to eq(401)
      expect(json['errors']).to_not be_blank
    end
  end

  context 'authorized' do
    before do
      FactoryGirl.create(:user,
                         email: 'a@user.com',
                         authentication_token: 'validtoken')
    end

    context 'view user' do
      context 'user does not exist' do
        it 'is not found' do
          get '/a/v1/users/id-not-in-system',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'

          expect(response.status).to eq(404)
          expect(json['errors']).to_not be_blank
        end
      end

      context 'user exists' do
        it 'is successful' do
          FactoryGirl.create(:user,
                             id: '4f16d362-a336-4b12-a133-4b8e39be7f8e',
                             username: 'xyz')

          get '/a/v1/users/4f16d362-a336-4b12-a133-4b8e39be7f8e',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'

          expect(response.status).to eq(200)
          expect(json['user']['id']).to eq(
            '4f16d362-a336-4b12-a133-4b8e39be7f8e')
          expect(json['user']['username']).to eq('xyz')
        end
      end
    end

    context 'list of faves' do
      context 'user exits' do
        before do
          FactoryGirl.create(
            :c_user,
            id: Cequel.uuid('de305d54-75b4-431b-adb2-eb6b9e546014')
          )

          FactoryGirl.create(
            :c_user_fave,
            c_user_id: Cequel.uuid('de305d54-75b4-431b-adb2-eb6b9e546014'),
            content_url: 'http://example.com/hello',
            id: '123e4567-e89b-12d3-a456-426655440000'
          )
        end

        it 'get list' do
          get '/a/v1/users/de305d54-75b4-431b-adb2-eb6b9e546014/faves',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'

          expect(response.status).to eq(200)
          expect(json['faves'][0]['content_url']).to eq('http://example.com/hello')
        end
      end
    end
  end
end
