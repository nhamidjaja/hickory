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
        get '/a/v1/search/user',
            nil,
            'X-Email' => 'a@user.com',
            'X-Auth-Token' => 'validtoken'

        expect(json['user']).to eq([])
      end
    end
  end
end
