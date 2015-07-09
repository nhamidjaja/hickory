require 'rails_helper'

RSpec.describe 'profile routes', type: :routing do
  it do
    expect(get('/api/v1/profile'))
      .to route_to(controller: 'api/v1/profile', action: 'index')
  end
end
