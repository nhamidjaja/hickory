require 'rails_helper'

RSpec.describe 'User Registrations API', type: :request do
  describe 'register through facebook' do
    context 'no token' do
      it 'is unauthorized' do
        post '/a/v1/registrations/facebook'

        expect(response.status).to eq(401)
        expect(json['errors']['message'])
          .to match('No Facebook token provided')
      end
    end

    context 'with invalid token' do
      before do
        expect_any_instance_of(FbGraph2::User)
          .to receive(:fetch)
          .and_raise(FbGraph2::Exception::InvalidToken, 'Invalid token')
      end

      it 'is unauthorized' do
        post '/a/v1/registrations/facebook',
             nil,
             'X-Facebook-Token' => 'invalid-token'

        expect(response.status).to eq(401)
        expect(json['errors']['message']).to match('Invalid token')
      end
    end

    context 'valid token' do
      let(:fb_user) do
        instance_double(
          'FbGraph2::User',
          email: 'new@email.com',
          id: 'x123',
          access_token: 'fb-token',
          name: 'John Doe',
          friends: []
        )
      end

      before do
        allow(FbGraph2::User).to receive(:me)
          .with('fb-token')
          .and_return(fb_user)
        allow(fb_user)
          .to receive(:fetch)
          .and_return(fb_user)
      end

      context 'valid user' do
        it 'creates user' do
          Sidekiq::Testing.inline! do
            expect do
              post '/a/v1/registrations/facebook',
                   '{"user": {"username": "nicholas"}}',
                   'Content-Type' => 'application/json',
                   'X-Facebook-Token' => 'fb-token'
            end.to change(User, :count).by(1)

            expect(response.status).to eq(201)
            expect(json['user']['email']).to match('new@email.com')
            expect(json['user']['username']).to match('nicholas')
            expect(json['user']['authentication_token']).to_not be_blank
            expect(ActionMailer::Base.deliveries.count).to eq(1)
          end
        end
      end

      context 'invalid user' do
        it 'is unprocessable entity' do
          post '/a/v1/registrations/facebook',
               '{"user": {"username": ""}}',
               'Content-Type' => 'application/json',
               'X-Facebook-Token' => 'fb-token'
          expect(response.status).to eq(422)
          expect(json['errors']['message']).to include('Username is invalid')
        end
      end

      describe 'suggested friends' do
        context 'no friends' do
          it do
            Sidekiq::Testing.inline! do
              expect do
                post '/a/v1/registrations/facebook',
                     '{"user": {"username": "nicholas"}}',
                     'Content-Type' => 'application/json',
                     'X-Facebook-Token' => 'fb-token'
              end.to_not change(Friend, :count)

              expect(response.status).to eq(201)
            end
          end
        end

        context 'one friend' do
          before do
            fb_friend = instance_double(
              'FbGraph2::User',
              id: '0987'
            )
            allow(fb_user).to receive(:friends).and_return([fb_friend])
          end

          context 'friend not found' do
            it do
              Sidekiq::Testing.inline! do
                expect do
                  post '/a/v1/registrations/facebook',
                       '{"user": {"username": "nicholas"}}',
                       'Content-Type' => 'application/json',
                       'X-Facebook-Token' => 'fb-token'
                end.to_not change(Friend, :count)

                expect(response.status).to eq(201)
              end
            end
          end

          context 'friend is found' do
            let(:friend) do
              FactoryGirl.create(:user, provider: 'facebook', uid: '0987')
            end

            before do
              expect(friend.in_cassandra.friends.size).to eq(0)
            end

            it do
              Sidekiq::Testing.inline! do
                expect do
                  post '/a/v1/registrations/facebook',
                       '{"user": {"username": "nicholas"}}',
                       'Content-Type' => 'application/json',
                       'X-Facebook-Token' => 'fb-token'
                end.to change(Friend, :count).by(2)

                expect(response.status).to eq(201)
                expect(friend.in_cassandra.friends.size).to eq(1)

                user = User.find_by_username('nicholas')
                expect(user.in_cassandra.friends.size).to eq(1)
              end
            end
          end
        end
      end
    end
  end
end
