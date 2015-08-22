require 'rails_helper'

RSpec.describe 'profile routes', type: :routing do
  it do
    expect(get('/a/v1/me/profile'))
      .to route_to(
        controller: 'a/v1/me/profile',
        action: 'index',
        format: :json)
  end

  it do
    expect(post('/a/v1/me/profile'))
      .to route_to(
        controller: 'a/v1/me/profile',
        action: 'create',
        format: :json)
  end
end
