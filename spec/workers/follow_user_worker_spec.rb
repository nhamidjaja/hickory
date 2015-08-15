require 'rails_helper'

RSpec.describe FollowUserWorker do
  describe '.perform' do
    let(:worker) { FollowUserWorker.new }
    let(:user) do
      FactoryGirl.build(
        :user,
        id: '4f16d362-a336-4b12-a133-4b8e39be7f8e')
    end
    let(:target) do
      FactoryGirl.build(
        :user,
        id: '9d6831a4-39d1-11e5-9128-17e501c711a8')
    end

    before do
      allow(User).to receive(:find)
        .with('4f16d362-a336-4b12-a133-4b8e39be7f8e')
        .and_return(user)
      allow(User).to receive(:find)
        .with('9d6831a4-39d1-11e5-9128-17e501c711a8')
        .and_return(target)
    end

    it 'receives User.follow' do
      expect(user).to receive(:follow).with(target).once
      worker.perform(
        '4f16d362-a336-4b12-a133-4b8e39be7f8e',
        '9d6831a4-39d1-11e5-9128-17e501c711a8')
    end
  end
end
