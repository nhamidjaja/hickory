require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  describe 'get user data' do
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
          expect(json['user']['id']).to eq(
            '4f16d362-a336-4b12-a133-4b8e39be7f8e')
          expect(json['user']['username']).to eq('xyz')
        end
      end
    end  
  end


  describe 'get user list of faves' do
    context 'unauthenticated' do
      it 'is unauthorized' do
        get '/a/v1/users/99a89669-557c-4c7a-a533-d1163caad65f/faves'

        expect(response.status).to eq(401)
        expect(json['errors']).to_not be_blank
      end
    end

    context 'authorized' do
      before do
        FactoryGirl.create(:user,
          id: 'de305d54-75b4-431b-adb2-eb6b9e546014',
         email: 'a@user.com',
         authentication_token: 'validtoken')
      end

      context 'user not exists' do
        it 'is not found' do
          get '/a/v1/users/id-not-found/faves',
          nil,
          'X-Email' => 'a@user.com',
          'X-Auth-Token' => 'validtoken'

          expect(response.status).to eq(404)
          expect(json['errors']).to_not be_blank
        end
      end

      context 'user exists' do
        context 'no faves yet' do
          it 'is empty' do
            get '/a/v1/users/de305d54-75b4-431b-adb2-eb6b9e546014/faves',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'

            expect(response.status).to eq(200)
            expect(json['faves']).to be_empty
          end
        end

        context 'one fave' do
          before do
            CUserFave.delete_all

            FactoryGirl.create(
              :c_user_fave,
              c_user_id: 'de305d54-75b4-431b-adb2-eb6b9e546014',
              id: '123e4567-e89b-12d3-a456-426655440000'
              )
          end

          it 'is successful' do
            get '/a/v1/users/de305d54-75b4-431b-adb2-eb6b9e546014/faves',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'

            expect(response.status).to eq(200)
            expect(json['faves'].size).to eq(1)

            fave = json['faves'].first
            expect(fave['id']).to eq('123e4567-e89b-12d3-a456-426655440000')
            expect(fave['content_url']).to_not be_blank
            expect(fave['title']).to_not be_blank
            expect(fave['image_url']).to_not be_blank
            expect(fave['published_at']).to_not be_blank
          end
        end

        context 'multiple faves' do
          let(:oldest_id) { Cequel.uuid(Time.zone.now - 1.months) }
          let(:middle_id) { Cequel.uuid(Time.zone.now - 1.weeks) }
          let(:newest_id) { Cequel.uuid(Time.zone.now) }
          before do
            CUserFave.delete_all

            [newest_id, oldest_id, middle_id].each do |i|
              FactoryGirl.create(
                :c_user_fave,
                c_user_id: 'de305d54-75b4-431b-adb2-eb6b9e546014',
                id: i
                )
            end
          end

          it 'is ordered' do
            get '/a/v1/users/de305d54-75b4-431b-adb2-eb6b9e546014/faves',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'

            expect(response.status).to eq(200)
            expect(json['faves'].size).to eq(3)
            expect(json['faves'][0]['id']).to eq(newest_id.to_s)
            expect(json['faves'][2]['id']).to eq(oldest_id.to_s)
          end

          it 'is paginated by last id' do
            get "/a/v1/users/de305d54-75b4-431b-adb2-eb6b9e546014/faves?last_id=#{middle_id.to_s}",
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'

            expect(response.status).to eq(200)
            expect(json['faves'].size).to eq(1)
            expect(json['faves'][0]['id']).to eq(oldest_id.to_s)
          end

          it 'is limited to 10' do
            11.times do |j|
              FactoryGirl.create(
                :c_user_fave,
                c_user_id: 'de305d54-75b4-431b-adb2-eb6b9e546014',
                id: Cequel.uuid(Time.zone.now)
                )
            end

            get '/a/v1/users/de305d54-75b4-431b-adb2-eb6b9e546014/faves',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'

            expect(response.status).to eq(200)
            expect(json['faves'].size).to eq(10)
          end
        end
      end
    end
  end
end
