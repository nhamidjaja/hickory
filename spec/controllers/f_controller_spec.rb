require 'rails_helper'

RSpec.describe FController, type: :controller do
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
        it 'queues job' do
          expect(FaveWorker).to receive(:perform_async)
            .with(
              current_user.id.to_s,
              'http://example.com/hello?source=xyz'
            ).once

          get :index, url: 'http://example.com/hello?source=xyz'
        end
      end
    end
  end
end
