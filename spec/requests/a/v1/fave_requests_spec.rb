require 'rails_helper'

RSpec.describe 'Search API', type: :request do
  context 'unauthenticated' do
    it 'is unauthorized' do
      get '/a/v1/fave'

      expect(response.status).to eq(401)
      expect(json['errors']).to_not be_blank
    end
  end

  context 'authorized' do
    before do
      FactoryGirl.create(:user,
                         email: 'a@user.com',
                         username: 'user',
                         authentication_token: 'validtoken')
    end

    context 'fave article' do
      it 'valid url' do
        get '/a/v1/fave?url=http://example.com/hello?source=xyz',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'

        expect(response.status).to eq(200)
      end
    end
  end
end
