require 'rails_helper'

RSpec.describe 'users routes', type: :routing do
  it 'GET show' do
    expect(get('/a/v1/users/some-id'))
      .to route_to(controller: 'a/v1/users',
                   action: 'show',
                   id: 'some-id',
                   format: :json)
  end

  it 'GET faves' do
    expect(get('/a/v1/users/some-id/faves'))
      .to route_to(controller: 'a/v1/users',
                   action: 'faves',
                   id: 'some-id',
                   format: :json)
  end

  it 'GET follow' do
    expect(get('/a/v1/users/some-id/follow'))
      .to route_to(controller: 'a/v1/users',
                   action: 'follow',
                   id: 'some-id',
                   format: :json)
  end

  it 'GET unfollow' do
    expect(get('/a/v1/users/some-id/unfollow'))
      .to route_to(controller: 'a/v1/users',
                   action: 'unfollow',
                   id: 'some-id',
                   format: :json)
  end

  it 'GET followers' do
    expect(get('/a/v1/users/some-id/followers'))
      .to route_to(controller: 'a/v1/users',
                   action: 'followers',
                   id: 'some-id',
                   format: :json)
   end
end
