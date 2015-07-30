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
        expect(json['user']['id']).to eq('4f16d362-a336-4b12-a133-4b8e39be7f8e')
        expect(json['user']['username']).to eq('xyz')
      end
    end
  end
end
