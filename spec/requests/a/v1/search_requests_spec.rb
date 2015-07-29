require 'rails_helper'

RSpec.describe 'Search API', type: :request do
  context 'unauthenticated' do
    it 'is unauthorized' do
      get '/a/v1/search'

      expect(response.status).to eq(401)
      expect(json['errors']).to_not be_blank
    end
  end

  context 'authorized' do
    before do
      FactoryGirl.create(:user,
                         email: 'a@user.com',
                         username: 'my_user',
                         authentication_token: 'validtoken')
    end
    context 'search user' do
      it 'not found' do
        get '/a/v1/search?query=qwer',
            nil,
            'X-Email' => 'a@user.com',
            'X-Auth-Token' => 'validtoken'

        expect(json['users']).to eq([])
      end

      it 'found 1 user' do
        get '/a/v1/search?query=my_user',
            nil,
            'X-Email' => 'a@user.com',
            'X-Auth-Token' => 'validtoken'

        expect(json['users'][0]['username']).to eq('my_user')
      end

      it 'found 2 data' do
        FactoryGirl.create(:user,
                           email: 'ab@userb.com',
                           username: 'user',
                           authentication_token: 'validtokenb')

        get '/a/v1/search?query=user',
            nil,
            'X-Email' => 'a@user.com',
            'X-Auth-Token' => 'validtoken'

        expect(json['users'].size).to eq(2)
      end
    end
  end
end
