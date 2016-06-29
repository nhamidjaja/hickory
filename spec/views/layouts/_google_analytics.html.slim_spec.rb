require 'rails_helper'

RSpec.describe 'layouts/_google_analytics.html.slim', type: :view do
  context 'unauthenticated' do
    it 'GA not have userId' do
      render

      expect(rendered).to include("ga('create', 'UA-62541080-2', 'auto');")
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
      allow(view).to receive(:current_user) { user }

      render

      expect(rendered).to include(
        "ga('create', 'UA-62541080-2', " \
          "{ 'userId': '4f16d362-a336-4b12-a133-4b8e39be7f8e' });"
      )
    end
  end
end
