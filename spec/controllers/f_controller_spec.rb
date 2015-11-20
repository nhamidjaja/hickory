require 'rails_helper'

RSpec.describe FController, type: :controller do
  describe 'GET #index' do
    context 'unsigned in user' do
      before { get :index }
      it { expect(response).to redirect_to(new_user_session_path) }
    end

    context 'signed in user' do
      login_user

      it 'queues job' do
        expect(FaveWorker).to receive(:perform_async)
          .with(
            current_user.id.to_s,
            'http://example.com/hello?source=xyz',
            kind_of(String)
          ).once

        get :index, url: 'http://example.com/hello?source=xyz'
      end
    end
  end
end
