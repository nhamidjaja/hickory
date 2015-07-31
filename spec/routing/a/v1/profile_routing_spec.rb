require 'rails_helper'

RSpec.describe 'profile routes', type: :routing do
  it do
    expect(get('/a/v1/profile'))
      .to route_to(controller: 'a/v1/profile', action: 'index', format: :json)
    expect(get('/a/v1/profile/update'))
      .to route_to(controller: 'a/v1/profile', action: 'update', format: :json)
  end
end
