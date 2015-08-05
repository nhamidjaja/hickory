require 'rails_helper'

RSpec.describe 'layouts/application.html.slim', type: :view do
  context 'unauthenticated' do
    it 'GA not have userId' do
      render template: 'layouts/application.html.slim'

      expect(rendered).to include('user = auto')
    end
  end

  context 'authorized' do
    let(:user) do
      FactoryGirl.build(:user,
                         email: 'a@user.com',
                         authentication_token: 'validtoken',
                         id: '4f16d362-a336-4b12-a133-4b8e39be7f8e')
    end

    it 'GA have userId' do
      allow(view).to receive(:current_user){ user }

      render template: 'layouts/application.html.slim'

      expect(rendered).to include(
        'user = {"userId":"4f16d362-a336-4b12-a133-4b8e39be7f8e"}')
    end
  end
end
