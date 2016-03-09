require 'rails_helper'

RSpec.describe 'Friends API', type: :request do
  describe 'get list of friends' do
    context 'unauthenticated' do
      it 'is unauthorized' do
        get '/a/v1/me/friends'

        expect(response.status).to eq(401)
        expect(json['errors']).to_not be_blank
      end
    end

    context 'authorized' do
      let(:user) do
        FactoryGirl.create(
          :user,
          id: '4f16d362-a336-4b12-a133-4b8e39be7f8e',
          email: 'a@user.com',
          authentication_token: 'validtoken')
      end
      let(:friend) do
        FactoryGirl.create(
          :user,
          id: 'de305d54-75b4-431b-adb2-eb6b9e546014',
          username: 'friend',
          full_name: 'John Doe')
      end
      let(:featured) do
        FactoryGirl.create(
          :user,
          id: 'f1ac29af-813e-4769-aaea-a0c697bbaa17',
          username: 'featured',
          full_name: 'Miranda Kerr')
      end

      before do
        user
        friend
      end

      describe 'suggested friends' do
        context 'no friends' do
          # it 'is successful' do
          #   get '/a/v1/me/friends',
          #       nil,
          #       'X-Email' => 'a@user.com',
          #       'X-Auth-Token' => 'validtoken'

          #   expect(response.status).to eq(200)
          #   expect(json['friends']).to eq([])
          # end
        end

        context 'one friend' do
          before do
            FactoryGirl.create(
              :friend,
              c_user: user.in_cassandra,
              id: friend.id.to_s
            )
          end

          # it 'is successful' do
          #   get '/a/v1/me/friends',
          #       nil,
          #       'X-Email' => 'a@user.com',
          #       'X-Auth-Token' => 'validtoken'

          #   expect(response.status).to eq(200)
          #   expect(json['friends'].size).to eq(1)

          #   friend = json['friends'].first
          #   expect(friend['id']).to eq('de305d54-75b4-431b-adb2-eb6b9e546014')
          #   expect(friend['username']).to eq('friend')
          #   expect(friend['full_name']).to eq('John Doe')
          # end
        end

        context 'one featured user' do
          before do
            Friend.delete_all
            FactoryGirl.create(
              :featured_user,
              user: featured
            )
          end

          # it 'is successful' do
          #   get '/a/v1/me/friends',
          #       nil,
          #       'X-Email' => 'a@user.com',
          #       'X-Auth-Token' => 'validtoken'

          #   expect(response.status).to eq(200)
          #   expect(json['friends'].size).to eq(1)

          #   friend = json['friends'].first
          #   expect(friend['id']).to eq('f1ac29af-813e-4769-aaea-a0c697bbaa17')
          #   expect(friend['username']).to eq('featured')
          #   expect(friend['full_name']).to eq('Miranda Kerr')
          # end
        end

        context 'many friends' do
          let(:oldest_id) { Cequel.uuid(Time.zone.now - 1.month) }
          let(:middle_id) { Cequel.uuid(Time.zone.now - 1.week) }
          let(:newest_id) { Cequel.uuid(Time.zone.now) }

          before do
            Friend.delete_all
            [newest_id, oldest_id, middle_id].each do |i|
              FactoryGirl.create(
                :user,
                id: i.to_s
              )
              FactoryGirl.create(
                :friend,
                c_user: user.in_cassandra,
                id: i)
            end
          end

          it 'is paginated by last_id' do
            get "/a/v1/me/friends?last_id=#{middle_id}",
                nil,
                'X-Email' => 'a@user.com',
                'X-Auth-Token' => 'validtoken'

            expect(response.status).to eq(200)
            expect(json['friends'].size).to eq(1)
            expect(json['friends'][0]['id']).to eq(newest_id.to_s)
          end

          # it 'is limited to 20' do
          #   21.times do |i|
          #     u = FactoryGirl.create(
          #       :user,
          #       username: 'user_' + i.to_s
          #     )
          #     FactoryGirl.create(
          #       :friend,
          #       c_user: user.in_cassandra,
          #       id: u.id
          #     )
          #   end

          #   get '/a/v1/me/friends',
          #       nil,
          #       'X-Email' => 'a@user.com',
          #       'X-Auth-Token' => 'validtoken'

          #   expect(response.status).to eq(200)
          #   expect(json['friends'].size).to eq(20)
          # end

          describe 'featured users' do
            before do
              FactoryGirl.create(
                :featured_user,
                user: featured
              )
            end

            it 'ignores last_id' do
              get "/a/v1/me/friends?last_id=#{middle_id}",
                  nil,
                  'X-Email' => 'a@user.com',
                  'X-Auth-Token' => 'validtoken'

              expect(response.status).to eq(200)
              expect(json['friends'].size).to eq(1)
              expect(json['friends'][0]['id']).to eq(newest_id.to_s)
            end

            # it 'is at the top' do
            #   get '/a/v1/me/friends',
            #       nil,
            #       'X-Email' => 'a@user.com',
            #       'X-Auth-Token' => 'validtoken'

            #   expect(response.status).to eq(200)
            #   expect(json['friends'][0]['id'])
            #     .to eq('f1ac29af-813e-4769-aaea-a0c697bbaa17')
            # end
          end
        end

        context 'many featured users' do
          before do
            6.times do |i|
              FactoryGirl.create(
                :featured_user,
                user: FactoryGirl.create(
                  :user,
                  username: "xyz#{i}"
                )
              )
            end
          end

          # it 'is limited to 3' do
          #   get '/a/v1/me/friends',
          #       nil,
          #       'X-Email' => 'a@user.com',
          #       'X-Auth-Token' => 'validtoken'

          #   expect(response.status).to eq(200)
          #   expect(json['friends'].size).to eq(3)
          # end
        end
      end
    end
  end
end
