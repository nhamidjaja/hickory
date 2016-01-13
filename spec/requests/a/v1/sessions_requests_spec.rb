require 'rails_helper'

RSpec.describe 'Sessions API', type: :request do
  describe 'login through facebook' do
    context 'no token' do
      before do
        get '/a/v1/sessions/facebook'
      end

      it { expect(response.status).to eq(401) }
    end

    context 'with invalid token' do
      before do
        double = instance_double('Koala::Facebook::API')
        expect(Koala::Facebook::API)
          .to receive(:new)
          .with('invalid-token', kind_of(String))
          .and_return(double)

        expect(double)
          .to receive(:get_object)
          .and_raise(Koala::Facebook::APIError.new(401, 'Invalid token'))
        get '/a/v1/sessions/facebook',
            nil,
            'X-Facebook-Token' => 'invalid-token'
      end

      it { expect(response.status).to eq(401) }
    end

    context 'valid token' do
      before do
        double = instance_double('Koala::Facebook::API')
        expect(Koala::Facebook::API)
          .to receive(:new)
          .with('fb-token', kind_of(String))
          .and_return(double)

        fb_user = {
          'email' => 'some@email.com',
          'id' => 'x123',
          'access_token' => 'fb-token',
          'name' => 'John Doe'
        }
        expect(double)
          .to receive(:get_object)
          .and_return(fb_user)
      end

      context 'new user' do
        it 'is not found' do
          get '/a/v1/sessions/facebook',
              nil,
              'X-Facebook-Token' => 'fb-token'

          expect(response.status).to eq(404)
          expect(json['errors']['message']).to match(/Unregistered user/)
        end
      end

      context 'existing email' do
        before do
          FactoryGirl.create(:user, email: 'some@email.com')
        end

        context 'valid facebook token' do
          it 'is successful' do
            get '/a/v1/sessions/facebook',
                nil,
                'X-Facebook-Token' => 'fb-token'

            expect(response.status).to eq(200)
            expect(json['user']['email']).to match('some@email.com')
            expect(json['user']['authentication_token']).to_not be_blank
          end
        end

        context 'unexpected error on save' do
          before do
            expect_any_instance_of(User)
              .to receive(:save!)
              .and_raise(StandardError, 'Failed to save')
          end

          it 'is server error' do
            get '/a/v1/sessions/facebook',
                nil,
                'X-Facebook-Token' => 'fb-token'

            expect(response.status).to eq(500)
            expect(json['errors']['message']).to_not be_blank
          end
        end
      end
    end
  end
end
