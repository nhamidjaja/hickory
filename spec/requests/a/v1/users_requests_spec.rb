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

    context 'view user' do
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

    context 'list of faves' do
      context 'user not exists' do
        it 'user id not uuid format' do
          get '/a/v1/users/id-not-uuid-format/faves',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'

          expect(response.status).to eq(404)
          expect(json['errors']).to_not be_blank
        end

        it 'user id uuid format but not exists' do
          get '/a/v1/users/de305d54-75b4-431b-adb2-eb6b9e546014/faves',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'

          expect(response.status).to eq(404)
          expect(json['errors']).to_not be_blank
        end
      end

      context 'user exits' do
        let(:c_user) do
          FactoryGirl.create(
            :c_user,
            id: Cequel.uuid('de305d54-75b4-431b-adb2-eb6b9e546014')
          )
        end

        let(:c_user_fave) do
          FactoryGirl.create(
            :c_user_fave,
            c_user_id: Cequel.uuid('de305d54-75b4-431b-adb2-eb6b9e546014'),
            content_url: 'http://example.com/hello',
            id: '03fc8cb0-39c0-11e5-98fe-5f1e283a6e35'
          )
        end

        before(:each) do
          CUserFave.destroy_all
        end

        context 'without parameter last_created_at' do
          subject do
            get '/a/v1/users/de305d54-75b4-431b-adb2-eb6b9e546014/faves',
                nil,
                'X-Email' => 'a@user.com',
                'X-Auth-Token' => 'validtoken'
          end

          context 'no fave data' do
            it 'successful and empty array' do
              c_user
              subject

              expect(response.status).to eq(200)
              expect(json['faves']).to eq([])
            end
          end

          context 'has 1 fave' do
            it 'get list' do
              c_user
              c_user_fave
              subject

              expect(response.status).to eq(200)
              expect(json['faves'][0]['content_url']).to eq('http://example.com/hello')
            end
          end

          context 'has many fave' do
            it 'is limit 10' do
              c_user
              c_user_fave

              11.times do
                FactoryGirl.create(
                  :c_user_fave,
                  c_user_id: Cequel.uuid(
                    'de305d54-75b4-431b-adb2-eb6b9e546014'),
                  content_url: 'http://example.com/hello',
                  id: Cequel.uuid(Time.zone.now)
                )
              end

              subject

              expect(response.status).to eq(200)
              expect(json['faves'].size).to eq(10)
            end

            it 'sort desc by id' do
              c_user
              c_user_fave

              FactoryGirl.create(
                :c_user_fave,
                c_user_id: Cequel.uuid('de305d54-75b4-431b-adb2-eb6b9e546014'),
                content_url: 'http://example.com/helloflyer',
                id: 'ce300438-39c2-11e5-98fe-5f1e283a6e35'
              )

              subject

              expect(response.status).to eq(200)
              expect(json['faves'][0]['content_url']).to eq('http://example.com/helloflyer')
              expect(json['faves'][1]['content_url']).to eq('http://example.com/hello')
            end
          end
        end

        context 'with parameter last_id' do
          it 'get older than last_id' do
            expect(CUserFave.count).to eq(0)

            c_user
            c_user_fave

            FactoryGirl.create(
              :c_user_fave,
              c_user_id: Cequel.uuid('de305d54-75b4-431b-adb2-eb6b9e546014'),
              content_url: 'http://example.com/helloflyer',
              id: 'ce300438-39c2-11e5-98fe-5f1e283a6e35'
            )

            FactoryGirl.create(
              :c_user_fave,
              c_user_id: Cequel.uuid('de305d54-75b4-431b-adb2-eb6b9e546014'),
              content_url: 'http://example.com/helloflyer2',
              id: 'a0dfcb74-39c4-11e5-98fe-5f1e283a6e35'
            )

            get '/a/v1/users/de305d54-75b4-431b-adb2-eb6b9e546014/faves',
                { last_id: 'a0dfcb74-39c4-11e5-98fe-5f1e283a6e35' },
                'X-Email' => 'a@user.com',
                'X-Auth-Token' => 'validtoken'

            expect(response.status).to eq(200)
            expect(json['faves'].size).to eq(2)
            expect(json['faves'][0]['content_url']).to eq('http://example.com/helloflyer')
            expect(json['faves'][1]['content_url']).to eq('http://example.com/hello')
          end
        end
      end
    end
  end
end
