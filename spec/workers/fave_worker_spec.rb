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

      it 'CUserFaveUrl count 0' do
        expect { subject  }
          .to change(CUserFaveUrl, :count).by(0)
      end

      it 'CUserFave count 0' do
        expect { subject }
          .to change(CUserFave, :count).by(0)
      end
    end
  end
end
