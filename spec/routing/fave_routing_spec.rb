require 'rails_helper'

RSpec.describe 'fave', type: :routing do
  it { expect(get('/fave')).to route_to(controller: 'fave', action: 'index') }
end
