require 'rails_helper'

RSpec.describe 'fave urls routes', type: :routing do
  it do
    expect(get('/a/v1/me/fave_urls'))
      .to route_to(controller: 'a/v1/me/fave_urls',
                   action: 'index',
                   format: :json)
  end
end
