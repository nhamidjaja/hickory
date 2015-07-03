require 'rails_helper'

RSpec.describe FaveController, type: :controller do
  context 'unsigned in user' do
    describe 'GET index' do
      before { get :index }
      it { expect(response).to redirect_to(new_user_session_path) }
    end
  end
end
