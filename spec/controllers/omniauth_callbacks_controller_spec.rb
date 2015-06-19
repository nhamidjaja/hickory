require 'rails_helper'

RSpec.describe OmniauthCallbacksController, type: :controller do
  describe '#facebook' do
    context 'returning user' do
      let(:user) { FactoryGirl.create(:user, provider: 'facebook', uid: 'x123') }
      before { allow(User).to receive(:from_omniauth) { user } }

      it 'signs in user' do
        expect(subject.current_user).to be_nil

        post :facebook

        expect(subject.current_user).to eq(user)
      end
    end

    context 'new user' do
      let(:user) { FactoryGirl.build(:user, provider: 'facebook', uid: 'x123') }
      before { 
        allow(User).to receive(:from_omniauth) { user } 
        controller.request.env['omniauth.auth'] = Hash.new
      }

      it 'stores omniauth in session' do
        post :facebook

        expect(session[:omniauth]).to_not be_nil
      end

      it 'redirects to registration' do
        post :facebook

        expect(response).to redirect_to(new_user_registration_path)
      end
    end
  end
end
