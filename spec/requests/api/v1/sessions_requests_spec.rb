require 'rails_helper'

RSpec.describe 'sessions', type: :request do
  context 'no token' do
    before do
      get '/api/v1/sessions/facebook'
    end

    it { expect(response.status).to eq(401) }
  end
end
