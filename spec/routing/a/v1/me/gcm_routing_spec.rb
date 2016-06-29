require 'rails_helper'

RSpec.describe 'gcm routes', type: :routing do
  it do
    expect(post('/a/v1/me/gcm'))
      .to route_to(
        controller: 'a/v1/me/gcm',
        action: 'create',
        format: :json
      )
  end
end
