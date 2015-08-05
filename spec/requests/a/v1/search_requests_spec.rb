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
    context 'search user by their username' do
      before do
        FactoryGirl.create(:user,
                           email: 'a@user.com',
                           username: 'user1',
                           authentication_token: 'validtoken')
      end

      context 'blank query' do
        it 'is empty' do
          # Do not do a database query when there is no input
          expect(User).to_not receive(:search_by_username)

          get '/a/v1/search',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'

          expect(response.status).to eq(200)
          expect(json['users']).to eq([])
        end
      end

      context 'has query' do
        subject do
          get '/a/v1/search?query=xo',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'
        end

        it 'is empty when there is no match' do
          subject

          expect(response.status).to eq(200)
          expect(json['users']).to eq([])
        end

        it 'exact matches' do
          FactoryGirl.create(:user, username: 'xo', full_name: 'Xo Xo')
          FactoryGirl.create(:user, username: 'abc')

          subject

          expect(response.status).to eq(200)
          expect(json['users'].size).to eq(1)
          expect(json['users'][0]['username']).to eq('xo')
          expect(json['users'][0]['full_name']).to eq('Xo Xo')
        end

        it 'partial matches' do
          FactoryGirl.create(:user, username: 'xoy', full_name: 'Xoy Xoy')
          FactoryGirl.create(:user, username: 'abc')

          subject

          expect(response.status).to eq(200)
          expect(json['users'].size).to eq(1)
          expect(json['users'][0]['username']).to eq('xoy')
          expect(json['users'][0]['full_name']).to eq('Xoy Xoy')
        end

        context 'several matches' do
          it 'is limited to 10' do
            11.times do |i|
              FactoryGirl.create(:user, username: 'xo' + i.to_s)
            end

            subject

            expect(response.status).to eq(200)
            expect(json['users'].size).to eq(10)
          end
        end
      end
    end
  end
end
