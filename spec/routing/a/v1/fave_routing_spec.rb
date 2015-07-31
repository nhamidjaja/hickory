require 'rails_helper'

RSpec.describe 'fave routes', type: :routing do
  it do
    expect(get('/a/v1/fave'))
      .to route_to(controller: 'a/v1/fave', action: 'index', format: :json)
  end
end
