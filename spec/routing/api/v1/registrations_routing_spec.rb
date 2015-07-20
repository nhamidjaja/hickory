require 'rails_helper'

RSpec.describe 'registrations routes', type: :routing do
  it do
    expect(post('/api/v1/registrations/facebook'))
      .to route_to(controller: 'api/v1/registrations',
                   action: 'facebook',
                   format: :json)
  end
end
