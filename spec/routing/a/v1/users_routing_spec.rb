require 'rails_helper'

RSpec.describe 'users routes', type: :routing do
  it 'view user profile ' do
    expect(get('/a/v1/users/some-id'))
      .to route_to(controller: 'a/v1/users',
                   action: 'show',
                   id: 'some-id',
                   format: :json)
  end

  it 'view user list of faves' do
    expect(get('/a/v1/users/some-id/faves'))
      .to route_to(controller: 'a/v1/users',
                   action: 'faves',
                   id: 'some-id',
                   format: :json)
  end
end
