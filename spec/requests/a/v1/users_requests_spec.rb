require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  context 'unauthenticated' do
    it 'is unauthorized' do
      get '/a/v1/top_articles'

      expect(response.status).to eq(401)
      expect(json['errors']).to_not be_blank
    end
  end

  context 'authorized' do
    before do
      FactoryGirl.create(:user,
                         id: '4f16d362-a336-4b12-a133-4b8e39be7f8e',
                         email: 'a@user.com',
                         username: 'user',
                         authentication_token: 'validtoken')
    end

    context 'view user' do
      context 'with not exists user id' do
        it 'is 500 user not found' do
          get '/a/v1/users/99a89669-557c-4c7a-a533-d1163caad65f',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'

          expect(response.status).to eq(500)
          expect(json['errors']).to_not be_blank
        end
      end

      context 'with exists user id' do
        it 'show user detail' do
          get '/a/v1/users/4f16d362-a336-4b12-a133-4b8e39be7f8e',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'

          expect(json['user']['username']).to eq('user')
        end
      end
    end
  end
end
