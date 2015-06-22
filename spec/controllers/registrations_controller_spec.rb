require 'rails_helper'

RSpec.describe RegistrationsController, type: :controller do
  before { request.env['devise.mapping'] = Devise.mappings[:user] }

  describe '#new' do
    context 'has omniauth session' do
      let(:info) { double(email: 'a@b.com') }
      let(:credentials) { double(token: 'abc098') }
      let(:callback) { double(provider: 'facebook', uid: '123', info: info, credentials: credentials) }

      before do
        request.session[:omniauth] = callback
        get :new
      end

      it { expect(assigns(:user).omniauth_token).to eq('abc098') }
    end
  end
end
