# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'On-boarding Featured Users API', type: :request do
  describe 'get list of featured users' do
    context 'unauthenticated' do
      it 'is successful' do
        get '/a/v1/featured_users'

        expect(response.status).to eq(200)
      end
    end

    context 'authenticated' do
      let(:user) do
        FactoryGirl.create(
          :user,
          id: '4f16d362-a336-4b12-a133-4b8e39be7f8e',
          email: 'a@user.com',
          authentication_token: 'validtoken'
        )
      end

      let(:featured) do
        FactoryGirl.create(
          :user,
          id: 'f1ac29af-813e-4769-aaea-a0c697bbaa17',
          username: 'featured',
          full_name: 'Miranda Kerr'
        )
      end

      before { user }

      context 'no featured users' do
        it 'is successful' do
          get '/a/v1/featured_users',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'

          expect(response.status).to eq(200)
          expect(json['featured_users']).to eq([])
        end
      end

      context 'one featured user' do
        before { featured }
        before do
          FactoryGirl.create(:featured_user,
                             user: featured)
        end

        it 'is successful' do
          get '/a/v1/featured_users',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'

          expect(response.status).to eq(200)
          expect(json['featured_users'].size).to eq(1)

          friend = json['featured_users'].first
          expect(friend['id']).to eq('f1ac29af-813e-4769-aaea-a0c697bbaa17')
          expect(friend['username']).to eq('featured')
          expect(friend['full_name']).to eq('Miranda Kerr')
        end
      end

      context 'many featured users' do
        before do
          51.times do |i|
            u = FactoryGirl.create(:user,
                                   username: 'user_' + i.to_s)
            FactoryGirl.create(:featured_user,
                               user: u)
          end
        end

        it 'is limited to 50' do
          get '/a/v1/featured_users',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'

          expect(response.status).to eq(200)
          expect(json['featured_users'].size).to eq(50)
        end
      end
    end
  end
end
