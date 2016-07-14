# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'featured users routes', type: :routing do
  it do
    expect(get('/a/v1/featured_users'))
      .to route_to(controller: 'a/v1/featured_users',
                   action: 'index', format: :json)
  end
end
