require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe FaveWorker do
  describe '.perform' do
    let(:user) { FactoryGirl.create(:user) }
    subject do
      FaveWorker.new.perform(
        'http://example.com/hello?source=xyz',
        user)
    end

    context 'test Fave::Url' do  
      it {
        double = instance_double('Fave::Url')

        expect(Fave::Url).to receive(:new).with('http://example.com/hello?source=xyz').and_return(double)
        expect(double).to receive(:canon).and_return('http://example.com/hello')

        subject
      }
    end
      
    context 'test CUserFave' do
      it {
        expect(CUserFave)
          .to receive(:create).with(
            c_user_id: user.id.to_s,
            id: anything,
            content_url: 'http://example.com/hello',
            headline: anything,
            image_url: anything,
            published_at: anything)
      
        subject
      }
    end

    context 'test Content' do
      it 'content exist' do
        FactoryGirl.create(:content, url: 'http://example.com/hello')

        double = class_double('Content')
        expect(Content).to receive(:where).with(
          url: 'http://example.com/hello').and_return(double)
        expect(double).to receive(:first)

        subject
      end

      it 'content not exist' do
        expect(Content).to receive(:new).with(
        url: 'http://example.com/hello')

        subject
      end
    end

    context 'test CUserFaveUrl' do
      it 'CUserFaveUrl exist' do
        FactoryGirl.create(:c_user_fave_url,
          c_user_id: user.id.to_s,
          content_url: 'http://example.com/hello')

        double = class_double('CUserFaveUrl')

        expect(CUserFaveUrl).to receive(:where).with(
          c_user_id: user.id.to_s,
          content_url: 'http://example.com/hello').and_return(double)
        expect(double).to receive(:first)

        subject
      end
    end

  end
end
