require 'rails_helper'
require 'rake'

RSpec.describe 'feeder namespace task' do
  before :all do
    Rake.application.rake_require 'tasks/feeder'
    Rake::Task.define_task(:environment)
  end

  describe 'feeder:refresh' do
    let :run_rake_task do
      Rake::Task['feeder:refresh'].reenable
      Rake.application.invoke_task 'feeder:refresh'
    end

    context 'one feed' do
      let(:feeder) { FactoryGirl.create(:feeder) }
      before { feeder }

      it do
        expect(PullFeedWorker).to receive(:perform_async)
          .with(feeder.id.to_s)
          .once

        run_rake_task
      end
    end
  end
end
