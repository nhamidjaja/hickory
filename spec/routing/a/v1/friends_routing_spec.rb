# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'friends routes', type: :routing do
  it do
    expect(get('/a/v1/friends'))
      .to route_to(controller: 'a/v1/friends',
                   action: 'index', format: :json)
  end
end
