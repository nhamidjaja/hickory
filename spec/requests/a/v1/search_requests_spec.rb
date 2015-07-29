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
          FactoryGirl.create(:user, username: 'xo')
          FactoryGirl.create(:user, username: 'abc')

          subject

          expect(response.status).to eq(200)
          expect(json['users'].size).to eq(1)
          expect(json['users'][0]['username']['xo'])
        end

        it 'partial matches' do
          FactoryGirl.create(:user, username: 'xoy')
          FactoryGirl.create(:user, username: 'abc')

          subject

          expect(response.status).to eq(200)
          expect(json['users'].size).to eq(1)
          expect(json['users'][0]['username']['xoy'])
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

    # context 'search user' do
    #   it 'not found and search by prefix' do
    #     get '/a/v1/search?query=ser',
    #         nil,
    #         'X-Email' => 'a@user.com',
    #         'X-Auth-Token' => 'validtoken'

    #     expect(json['users']).to eq([])
    #   end

    #   it 'found 1 user' do
    #     get '/a/v1/search?query=user',
    #         nil,
    #         'X-Email' => 'a@user.com',
    #         'X-Auth-Token' => 'validtoken'

    #     expect(json['users'][0]['username']).to eq('user1')
    #   end

    #   it 'found 2 data' do
    #     FactoryGirl.create(:user,
    #                        email: 'ab@userb.com',
    #                        username: 'user2',
    #                        authentication_token: 'validtokenb')

    #     get '/a/v1/search?query=user',
    #         nil,
    #         'X-Email' => 'a@user.com',
    #         'X-Auth-Token' => 'validtoken'

    #     expect(json['users'].size).to eq(2)
    #   end
    # end
  end
end
