require 'rails_helper'

RSpec.describe 'friends routes', type: :routing do
  it do
    expect(get('/a/v1/me/friends'))
      .to route_to(
        controller: 'a/v1/me/friends',
        action: 'index',
        format: :json
      )
  end
end
