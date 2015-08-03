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
        # it 'creates a new CUserFaveUrl' do
        #   expect { get :index, url: 'http://example.com/hello?source=xyz' }
        #     .to change(CUserFaveUrl, :count).by(1)
        # end

        it 'make sure call FaveWorker' do
          expect(FaveWorker).to receive(:perform_async).with(@current_user.id,
                                                             'http://example.com/hello?source=xyz').once

          get :index, url: 'http://example.com/hello?source=xyz'
        end

        # it 'creates a new CUserFave' do
        #   expect { get :index, url: 'http://example.com/hello?source=xyz' }
        #     .to change(CUserFave, :count).by(1)
        # end

        it 'make sure FaveWorker run in queueing' do
          expect do
            FaveWorker.perform_async(@current_user.id, 'http://example.com/hello?source=xyz')
          end.to change(FaveWorker.jobs, :size).by(1)
        end
      end
    end
  end
end
