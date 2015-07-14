require 'rails_helper'
require 'rake'

RSpec.describe 'master_feed namespace task' do
  before :all do
    Rake.application.rake_require "tasks/master_feed"
    Rake::Task.define_task(:environment)
  end

  describe 'master_feed:refresh' do
    let :run_rake_task do
      Rake::Task["master_feed:refresh"].reenable
      Rake.application.invoke_task "master_feed:refresh"
    end

    it 'clears queue' # do
      # expect_any_instance_of('Sidekiq::Queue').to receive(:clear).once

      # run_rake_task
    # end
  end
end
