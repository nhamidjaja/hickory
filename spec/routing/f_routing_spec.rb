require 'rails_helper'

RSpec.describe 'routes for fave', type: :routing do
  it { expect(get('/f')).to route_to(controller: 'f', action: 'index') }
  it do
    expect(get('/f/preview'))
      .to route_to(controller: 'f', action: 'preview')
  end
end
