require 'rails_helper'

RSpec.describe TopArticle, type: :model do
  it { expect(FactoryGirl.build(:top_article)).to be_valid }
end
