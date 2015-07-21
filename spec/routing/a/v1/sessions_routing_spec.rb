require 'rails_helper'

RSpec.describe 'sessions routes', type: :routing do
  it do
    expect(get('/a/v1/sessions/facebook'))
      .to route_to(controller: 'a/v1/sessions',
                   action: 'facebook',
                   format: :json)
  end
end
