# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'feed routes', type: :routing do
  it 'GET index' do
    expect(get('/a/v1/feed'))
      .to route_to(controller: 'a/v1/feed',
                   action: 'index',
                   format: :json)
  end
end
