require 'rails_helper'

RSpec.describe 'master feeds routes', type: :routing do
  it do
    expect(get('/api/v1/master_feeds'))
      .to route_to(controller: 'api/v1/master_feeds', action: 'index', format: :json)
  end
end
