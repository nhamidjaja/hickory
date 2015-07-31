require 'rails_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

RSpec.describe 'Search API', type: :request do
  context 'unauthenticated' do
    it 'is unauthorized' do
      get '/a/v1/fave'

      expect(response.status).to eq(401)
      expect(json['errors']).to_not be_blank
    end
  end

  context 'authorized' do
    let(:user) do
      FactoryGirl.create(:user,
                         email: 'a@user.com',
                         username: 'user',
                         authentication_token: 'validtoken')
    end
    before do
      user
    end

    context 'fave article' do
      it 'make sure fave API call FaveWorker' do
        expect(FaveWorker).to receive(:perform_async).with(
          'http://example.com/hello?source=xyz', user).once

        get '/a/v1/fave?url=http://example.com/hello?source=xyz',
            nil,
            'X-Email' => 'a@user.com',
            'X-Auth-Token' => 'validtoken'

        expect(response.status).to eq(200)
      end

      it 'make sure FaveWorker run in queueing' do
        expect do
          FaveWorker.perform_async('http://example.com/hello?source=xyz', user)
        end.to change(FaveWorker.jobs, :size).by(1)
      end
    end
  end
end
