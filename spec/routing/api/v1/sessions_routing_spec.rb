require 'rails_helper'

RSpec.describe 'sessions routes', type: :routing do
  it do
    expect(get('/api/v1/sessions/facebook'))
      .to route_to(controller: 'api/v1/sessions', action: 'facebook')
  end
end
