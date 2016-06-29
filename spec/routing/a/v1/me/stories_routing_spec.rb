require 'rails_helper'

RSpec.describe 'stories routes', type: :routing do
  it do
    expect(get('/a/v1/me/stories'))
      .to route_to(
        controller: 'a/v1/me/stories',
        action: 'index',
        format: :json
      )
  end
end
