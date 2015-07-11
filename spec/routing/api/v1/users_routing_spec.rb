require 'rails_helper'

RSpec.describe 'users routes', type: :routing do
  it do
    expect(get('/api/v1/users/some-id'))
      .to route_to(controller: 'api/v1/users', action: 'show', id: 'some-id', format: :json)
  end
end
