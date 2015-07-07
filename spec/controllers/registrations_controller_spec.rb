require 'rails_helper'

RSpec.describe RegistrationsController, type: :controller do
  before { request.env['devise.mapping'] = Devise.mappings[:user] }

  describe '#new' do
    context 'has omniauth session' do
      let(:callback) do
        { 'provider' => 'facebook', 'uid' => '123',
          'info' => { 'email' => 'a@b.com' },
          'credentials' => { 'token' => 'abc098' } }
      end

      before do
        request.session[:omniauth] = callback
        get :new
      end

      it { expect(assigns(:user).omniauth_token).to eq('abc098') }
    end

    context 'no omniauth session' do
      before do
        get :new
      end

      it { expect(assigns(:user).omniauth_token).to eq(nil) }
    end
  end
end
