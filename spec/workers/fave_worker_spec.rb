require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe FaveWorker do
  describe '.perform' do
    context 'valid url' do
      let(:user) { FactoryGirl.create(:user) }

      subject do
        FaveWorker.new.perform(
          'http://example.com/hello?source=xyz',
          user)
      end

      it 'creates a new CUserFaveUrl' do
        expect { subject  }
          .to change(CUserFaveUrl, :count).by(1)
      end

      it 'creates a new CUserFave' do
        expect { subject }
          .to change(CUserFave, :count).by(1)
      end
    end

    context 'invalid url' do
      let(:user) { FactoryGirl.create(:user) }

      subject { FaveWorker.new.perform('asdasds', user) }

      it 'raise error' do
        expect { subject  }
          .to raise_error
      end
    end
  end
end
