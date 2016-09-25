# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'publications routes', type: :routing do
  it 'GET index' do
    expect(get('/a/v1/publications'))
      .to route_to(controller: 'a/v1/publications',
                   action: 'index',
                   format: :json)
  end

  it 'GET show' do
    expect(get('/a/v1/publications/some-id'))
      .to route_to(controller: 'a/v1/publications',
                   action: 'show',
                   id: 'some-id',
                   format: :json)
  end

  it 'GET featured' do
    expect(get('/a/v1/publications/featured'))
      .to route_to(controller: 'a/v1/publications',
                   action: 'featured',
                   format: :json)
  end
  it 'GET subscribe' do
    expect(get('/a/v1/publications/some-id/subscribe'))
      .to route_to(controller: 'a/v1/publications',
                   action: 'subscribe',
                   id: 'some-id',
                   format: :json)
  end

  it 'GET unsubscribe' do
    expect(get('/a/v1/publications/some-id/unsubscribe'))
      .to route_to(controller: 'a/v1/publications',
                   action: 'unsubscribe',
                   id: 'some-id',
                   format: :json)
  end
end
