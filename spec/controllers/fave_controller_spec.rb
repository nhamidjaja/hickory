require 'rails_helper'

RSpec.describe FaveController, type: :controller do
  context 'unsigned in user' do
    describe 'GET #index' do
      before { get :index }
      it { expect(response).to redirect_to(new_user_session_path) }
    end
  end

  context 'signed in user' do
    login_user

    describe 'GET #index' do
      context 'valid url' do
        it 'creates a new UserFave' do
          expect { get :index, url: 'http://example.com/hello?source=xyz' }.to change(UserFave, :count).by(1)
        end
      end
    end
  end
end
