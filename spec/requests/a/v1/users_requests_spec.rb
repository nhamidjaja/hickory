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
          # Rspec workaround to reset counter
          CUserCounter['4f16d362-a336-4b12-a133-4b8e39be7f8e'].destroy

          FactoryGirl.create(:user,
                             id: '4f16d362-a336-4b12-a133-4b8e39be7f8e',
                             username: 'xyz',
                             full_name: 'Xyz Xyz',
                             description: 'Xyz Description')
          21.times do
            FactoryGirl.create(:c_user_fave,
                               c_user_id: '4f16d362-a336-4b12-a133-4b8e39be7f8e'
                              )
          end

          get '/a/v1/users/4f16d362-a336-4b12-a133-4b8e39be7f8e',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'

          expect(response.status).to eq(200)
          expect(json['user']['id']).to eq(
            '4f16d362-a336-4b12-a133-4b8e39be7f8e')
          expect(json['user']['username']).to eq('xyz')
          expect(json['user']['full_name']).to eq('Xyz Xyz')
          expect(json['user']['description']).to eq('Xyz Description')
          expect(json['user']['faves_count']).to eq(0)
          expect(json['user']['followers_count']).to eq(0)
          expect(json['user']['followings_count']).to eq(0)
          expect(json['user']['is_following']).to eq(false)
          expect(json['user']['recent_faves'].count).to eq(20)
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
        CUserFave.delete_all
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
            expect(fave['published_at']).to be_a(Fixnum)
            expect(fave['faved_at']).to_not be_blank
            expect(fave['faved_at']).to be_a(Fixnum)
          end
        end

        context 'multiple faves' do
          let(:oldest_id) { Cequel.uuid(Time.zone.now - 1.month) }
          let(:middle_id) { Cequel.uuid(Time.zone.now - 1.week) }
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
            get '/a/v1/users/de305d54-75b4-431b-adb2-eb6b9e546014' \
            "/faves?last_id=#{middle_id}",
                nil,
                'X-Email' => 'a@user.com',
                'X-Auth-Token' => 'validtoken'

            expect(response.status).to eq(200)
            expect(json['faves'].size).to eq(1)
            expect(json['faves'][0]['id']).to eq(oldest_id.to_s)
          end

          it 'is limited to 10' do
            11.times do
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

  describe 'follow a user' do
    context 'unauthenticated' do
      it 'is unauthorized' do
        get '/a/v1/users/99a89669-557c-4c7a-a533-d1163caad65f/follow'

        expect(response.status).to eq(401)
        expect(json['errors']).to_not be_blank
      end
    end

    context 'authorized' do
      let(:user) do
        FactoryGirl.create(
          :user,
          id: 'de305d54-75b4-431b-adb2-eb6b9e546014',
          email: 'a@user.com',
          authentication_token: 'validtoken')
      end
      let(:target) do
        FactoryGirl.create(
          :user,
          id: '123e4567-e89b-12d3-a456-426655440000')
      end

      before do
        user

        CUserFave.delete_all
        3.times do
          FactoryGirl.create(
            :c_user_fave,
            c_user: target.in_cassandra
          )
        end

        FactoryGirl.create(
          :friend,
          c_user: user.in_cassandra,
          id: target.id.to_s)
      end

      context 'user not exists' do
        it 'is not found' do
          get '/a/v1/users/id-not-found/follow',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'

          expect(response.status).to eq(404)
          expect(json['errors']).to_not be_blank
        end
      end

      context 'user is self' do
        it 'is unprocessable entity' do
          get '/a/v1/users/de305d54-75b4-431b-adb2-eb6b9e546014/follow',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'

          expect(response.status).to eq(422)
          expect(json['errors']).to_not be_blank
        end
      end

      context 'user exists' do
        it 'is successful' do
          Sidekiq::Testing.inline! do
            expect(user.following?(target)).to eq(false)

            expect(target.faves.count).to eq(3)
            expect(user.in_cassandra.stories.count).to eq(0)

            expect(user.in_cassandra.friends.count).to eq(1)

            expect_any_instance_of(CUser).to receive(:increment_follow_counters)

            expect do
              get '/a/v1/users/123e4567-e89b-12d3-a456-426655440000/follow',
                  nil,
                  'X-Email' => 'a@user.com',
                  'X-Auth-Token' => 'validtoken'
            end.to change { [Follower.count, Following.count] }.to([1, 1])

            expect(response.status).to eq(200)
            expect(json).to be_blank

            expect(user.following?(target)).to eq(true)
            expect(target.in_cassandra.followers.where(
              id: 'de305d54-75b4-431b-adb2-eb6b9e546014').first).to_not be_nil

            # expect(CUserCounter['de305d54-75b4-431b-adb2-eb6b9e546014']
            #   .followings).to eq(1)
            # expect(CUserCounter['123e4567-e89b-12d3-a456-426655440000']
            #   .followers).to eq(1)

            # Merge target's faves into user's stories
            expect(user.in_cassandra.stories.count).to eq(3)

            # Remove target from friends
            expect(user.in_cassandra.friends.count).to eq(0)
          end
        end
      end
    end
  end

  describe 'unfollow user' do
    context 'unauthenticated' do
      it 'is unauthorized' do
        get '/a/v1/users/99a89669-557c-4c7a-a533-d1163caad65f/unfollow'

        expect(response.status).to eq(401)
        expect(json['errors']).to_not be_blank
      end
    end

    context 'authorized' do
      let(:user) do
        FactoryGirl.create(
          :user,
          id: 'de305d54-75b4-431b-adb2-eb6b9e546014',
          email: 'a@user.com',
          authentication_token: 'validtoken')
      end
      let(:target) do
        FactoryGirl.create(
          :user,
          id: '123e4567-e89b-12d3-a456-426655440000')
      end

      before do
        user

        user.in_cassandra.follow(target.in_cassandra)
        expect(user.following?(target)).to eq(true)

        CUserFave.delete_all
        Story.delete_all
        3.times do
          id = Cequel.uuid(Time.zone.now)

          FactoryGirl.create(:c_user_fave,
                             c_user: target.in_cassandra,
                             id: id
                            )
          FactoryGirl.create(:story,
                             c_user: user.in_cassandra,
                             id: id
                            )
        end
      end

      context 'user not exists' do
        it 'is not found' do
          get '/a/v1/users/id-not-found/unfollow',
              nil,
              'X-Email' => 'a@user.com',
              'X-Auth-Token' => 'validtoken'

          expect(response.status).to eq(404)
          expect(json['errors']).to_not be_blank
        end
      end

      context 'user exists' do
        it 'is successful' do
          Sidekiq::Testing.inline! do
            # Reset counters
            CUserCounter['de305d54-75b4-431b-adb2-eb6b9e546014'].destroy
            CUserCounter['123e4567-e89b-12d3-a456-426655440000'].destroy

            expect_any_instance_of(CUser).to receive(:decrement_follow_counters)

            expect(target.faves.size).to eq(3)
            expect(user.in_cassandra.stories.size).to eq(3)

            expect do
              get '/a/v1/users/123e4567-e89b-12d3-a456-426655440000/unfollow',
                  nil,
                  'X-Email' => 'a@user.com',
                  'X-Auth-Token' => 'validtoken'
            end.to change { [Follower.count, Following.count] }.to([0, 0])

            expect(response.status).to eq(200)
            expect(json).to be_blank

            expect(user.following?(target)).to eq(false)
            expect(target.in_cassandra.followers.where(
              id: 'de305d54-75b4-431b-adb2-eb6b9e546014').first).to be_nil

            expect(user.in_cassandra.stories.size).to eq(0)

            # counters do not work properly in spec
            # expect(CUserCounter['de305d54-75b4-431b-adb2-eb6b9e546014']
            #   .followings).to eq(0)
            # expect(CUserCounter['123e4567-e89b-12d3-a456-426655440000']
            #   .followers).to eq(0)
          end
        end
      end
    end
  end

  describe 'get list of followers' do
    context 'unauthenticated' do
      it 'is unauthorized' do
        get '/a/v1/users/99a89669-557c-4c7a-a533-d1163caad65f/followers'

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
        Follower.delete_all
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
        context 'no followers' do
          it 'is empty' do
            get '/a/v1/users/de305d54-75b4-431b-adb2-eb6b9e546014/followers',
                nil,
                'X-Email' => 'a@user.com',
                'X-Auth-Token' => 'validtoken'

            expect(response.status).to eq(200)
            expect(json['followers']).to be_empty
          end
        end

        context 'one follower' do
          before do
            Follower.delete_all

            FactoryGirl.create(:user,
                               id: '123e4567-e89b-12d3-a456-426655440000',
                               username: 'some_user',
                               full_name: 'John Doe'
                              )
            FactoryGirl.create(
              :follower,
              c_user_id: 'de305d54-75b4-431b-adb2-eb6b9e546014',
              id: '123e4567-e89b-12d3-a456-426655440000'
            )
          end

          it 'is successful' do
            get '/a/v1/users/de305d54-75b4-431b-adb2-eb6b9e546014/followers',
                nil,
                'X-Email' => 'a@user.com',
                'X-Auth-Token' => 'validtoken'

            expect(response.status).to eq(200)
            expect(json['followers'].size).to eq(1)

            follower = json['followers'].first
            expect(follower['id']).to eq('123e4567-e89b-12d3-a456-426655440000')
            expect(follower['username']).to eq('some_user')
            expect(follower['full_name']).to eq('John Doe')
          end
        end

        context 'multiple followers' do
          let(:oldest_id) { Cequel.uuid(Time.zone.now - 1.month) }
          let(:middle_id) { Cequel.uuid(Time.zone.now - 1.week) }
          let(:newest_id) { Cequel.uuid(Time.zone.now) }
          before do
            [newest_id, oldest_id, middle_id].each do |i|
              FactoryGirl.create(:user,
                                 id: i.to_s
                                )
              FactoryGirl.create(
                :follower,
                c_user_id: 'de305d54-75b4-431b-adb2-eb6b9e546014',
                id: i
              )
            end
          end

          it 'is paginated by last id' do
            get '/a/v1/users/de305d54-75b4-431b-adb2-eb6b9e546014' \
            "/followers?last_id=#{middle_id}",
                nil,
                'X-Email' => 'a@user.com',
                'X-Auth-Token' => 'validtoken'

            expect(response.status).to eq(200)
            expect(json['followers'].size).to eq(1)
            expect(json['followers'][0]['id']).to eq(oldest_id.to_s)
          end

          it 'is limited to 30' do
            31.times do
              u = FactoryGirl.create(:user)
              FactoryGirl.create(
                :follower,
                c_user_id: 'de305d54-75b4-431b-adb2-eb6b9e546014',
                id: u.id.to_s
              )
            end

            get '/a/v1/users/de305d54-75b4-431b-adb2-eb6b9e546014/followers',
                nil,
                'X-Email' => 'a@user.com',
                'X-Auth-Token' => 'validtoken'

            expect(response.status).to eq(200)
            expect(json['followers'].size).to eq(30)
          end
        end
      end
    end
  end

  describe 'get list of followings' do
    context 'unauthenticated' do
      it 'is unauthorized' do
        get '/a/v1/users/99a89669-557c-4c7a-a533-d1163caad65f/followings'

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
        Following.delete_all
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
        context 'no followings' do
          it 'is empty' do
            get '/a/v1/users/de305d54-75b4-431b-adb2-eb6b9e546014/followings',
                nil,
                'X-Email' => 'a@user.com',
                'X-Auth-Token' => 'validtoken'

            expect(response.status).to eq(200)
            expect(json['followings']).to be_empty
          end
        end

        context 'one following' do
          before do
            Following.delete_all

            FactoryGirl.create(:user,
                               id: '123e4567-e89b-12d3-a456-426655440000',
                               username: 'some_user',
                               full_name: 'John Doe'
                              )
            FactoryGirl.create(
              :following,
              c_user_id: 'de305d54-75b4-431b-adb2-eb6b9e546014',
              id: '123e4567-e89b-12d3-a456-426655440000'
            )
          end

          it 'is successful' do
            get '/a/v1/users/de305d54-75b4-431b-adb2-eb6b9e546014/followings',
                nil,
                'X-Email' => 'a@user.com',
                'X-Auth-Token' => 'validtoken'

            expect(response.status).to eq(200)
            expect(json['followings'].size).to eq(1)

            following = json['followings'].first
            expect(following['id'])
              .to eq('123e4567-e89b-12d3-a456-426655440000')
            expect(following['username']).to eq('some_user')
            expect(following['full_name']).to eq('John Doe')
          end
        end

        context 'multiple followings' do
          let(:oldest_id) { Cequel.uuid(Time.zone.now - 1.month) }
          let(:middle_id) { Cequel.uuid(Time.zone.now - 1.week) }
          let(:newest_id) { Cequel.uuid(Time.zone.now) }
          before do
            [newest_id, oldest_id, middle_id].each do |i|
              FactoryGirl.create(:user,
                                 id: i.to_s
                                )
              FactoryGirl.create(
                :following,
                c_user_id: 'de305d54-75b4-431b-adb2-eb6b9e546014',
                id: i
              )
            end
          end

          it 'is paginated by last id' do
            get '/a/v1/users/de305d54-75b4-431b-adb2-eb6b9e546014' \
            "/followings?last_id=#{middle_id}",
                nil,
                'X-Email' => 'a@user.com',
                'X-Auth-Token' => 'validtoken'

            expect(response.status).to eq(200)
            expect(json['followings'].size).to eq(1)
            expect(json['followings'][0]['id']).to eq(oldest_id.to_s)
          end

          it 'is limited to 30' do
            31.times do
              u = FactoryGirl.create(:user)
              FactoryGirl.create(
                :following,
                c_user_id: 'de305d54-75b4-431b-adb2-eb6b9e546014',
                id: u.id.to_s
              )
            end

            get '/a/v1/users/de305d54-75b4-431b-adb2-eb6b9e546014/followings',
                nil,
                'X-Email' => 'a@user.com',
                'X-Auth-Token' => 'validtoken'

            expect(response.status).to eq(200)
            expect(json['followings'].size).to eq(30)
          end
        end
      end
    end
  end
end
