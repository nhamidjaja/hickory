require 'rails_helper'

RSpec.describe 'top articles routes', type: :routing do
  it do
    expect(get('/a/v1/top_articles'))
      .to route_to(controller: 'a/v1/top_articles',
                   action: 'index', format: :json)
  end
end
