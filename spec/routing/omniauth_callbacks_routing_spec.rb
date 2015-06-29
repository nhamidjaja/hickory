require 'rails_helper'

RSpec.describe 'omniauth callbacks', type: :routing do
  it 'routes to OmniauthCallbacks#facebook' do
    expect(get('/users/auth/facebook/callback')).to route_to(controller: 'omniauth_callbacks', action: 'facebook')
  end
end
