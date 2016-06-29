require 'rails_helper'

RSpec.describe 'Search API', type: :request do
  context 'unauthenticated' do
    before do
      FactoryGirl.create(:user,
                         email: 'a@user.com',
                         username: 'user1',
                         full_name: '',
                         authentication_token: 'validtoken')
    end

    describe 'search User by username' do
      context 'blank query' do
        it 'is empty' do
          # Do not do a database query when there is no input
          expect(User).to_not receive(:search)

          get '/a/v1/search',
              nil

          expect(response.status).to eq(200)
          expect(json['users']).to eq([])
        end
      end

      context 'has query' do
        subject do
          get '/a/v1/search?query=xo',
              nil
        end

        it 'is empty when there is no match' do
          subject

          expect(response.status).to eq(200)
          expect(json['users']).to eq([])
        end

        it 'exact matches' do
          FactoryGirl.create(:user,
                             username: 'xo',
                             full_name: 'Xo Xo',
                             description: 'just a guy',
                             profile_picture_url: 'http://a.xyz/b.jpg')
          FactoryGirl.create(:user, username: 'abc')

          subject

          expect(response.status).to eq(200)
          expect(json['users'].size).to eq(1)
          expect(json['users'][0]['username']).to eq('xo')
          expect(json['users'][0]['full_name']).to eq('Xo Xo')
          expect(json['users'][0]['description']).to eq('just a guy')
          expect(json['users'][0]['profile_picture_url'])
            .to eq('http://a.xyz/b.jpg')
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

    describe 'search User by full_name' do
      it 'partial matches' do
        FactoryGirl.create(:user,
                           username: 'ab',
                           full_name: 'john')
        get '/a/v1/search?query=jo',
            nil
      end
    end
  end
end
