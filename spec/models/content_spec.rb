require 'rails_helper'

RSpec.describe Content, type: :model do
  it { expect(FactoryGirl.build(:content)).to be_valid }

  it { expect(FactoryGirl.build(:content, url: '')).to_not be_valid }

  describe '.url=' do
    it { expect(FactoryGirl.build(:content, url: 'https://abc.com').url).to eq('http://abc.com') }
    it { expect(FactoryGirl.build(:content, url: 'http://abc.com/a?x=y').url).to eq('http://abc.com/a') }
  end

  describe '#find_or_initialize_by' do
    let(:content) { FactoryGirl.build(:content, url: 'http://example.com') }
    subject { Content.find_or_initialize_by(url: 'http://example.com') }

    context 'found' do
      it 'has content' do
        expect(Content).to receive(:where)
          .with(url: 'http://example.com')
          .and_return([content])

        is_expected.to eq(content)
      end
    end

    context 'not found' do
      it 'is new' do
        expect(Content).to receive(:where)
          .with(url: 'http://example.com')
          .and_return([])
        expect(Content).to receive(:new)
          .with(url: 'http://example.com')
          .and_return(content)

        is_expected.to eq(content)
      end
    end
  end
end
