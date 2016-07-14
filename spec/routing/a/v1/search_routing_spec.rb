# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'search routes', type: :routing do
  it do
    expect(get('/a/v1/search'))
      .to route_to(controller: 'a/v1/search', action: 'index', format: :json)
  end
end
