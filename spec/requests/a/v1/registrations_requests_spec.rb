# frozen_string_literal: true
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
        double = instance_double('Koala::Facebook::API')
        expect(Koala::Facebook::API)
          .to receive(:new)
          .with('invalid-token', kind_of(String))
          .and_return(double)

        allow(double)
          .to receive(:get_object)
          .and_raise(Koala::Facebook::APIError.new(401, 'Invalid token'))
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
      let(:koala) do
        instance_double('Koala::Facebook::API')
      end

      before do
        expect(Koala::Facebook::API)
          .to receive(:new)
          .at_least(:once)
          .with('fb-token', kind_of(String))
          .and_return(koala)

        fb_user = {
          'email' => 'some@email.com',
          'id' => 'x123',
          'access_token' => 'fb-token',
          'name' => 'John Doe',
          'picture' =>
          { 'data' =>
            {
              'url' => 'http://abc.com/123.jpg'
            } }
        }
        allow(koala)
          .to receive(:get_object)
          .with('me', 'fields' => 'email,name,id,picture.type(normal)')
          .and_return(fb_user)
        allow(koala)
          .to receive(:get_connections)
          .with('me', 'friends')
          .and_return([])
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
            expect(json['user']['email']).to match('some@email.com')
            expect(json['user']['username']).to match('nicholas')
            expect(json['user']['authentication_token']).to_not be_blank
            expect(json['user']['profile_picture_url']).to eq('http://abc.com/123.jpg')
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
          before do
            expect(koala)
              .to receive(:get_connections)
              .with('me', 'friends')
              .and_return([])
          end

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
            expect(koala)
              .to receive(:get_connections)
              .with('me', 'friends')
              .and_return([
                            { 'name' => 'John Doe',
                              'id' => '0987' }
                          ])
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
