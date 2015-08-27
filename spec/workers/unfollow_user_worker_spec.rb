require 'rails_helper'

RSpec.describe UnfollowUserWorker do
  describe '.perform' do
    let(:worker) { UnfollowUserWorker.new }
    let(:user) do
      FactoryGirl.build(
        :c_user,
        id: '4f16d362-a336-4b12-a133-4b8e39be7f8e')
    end
    let(:target) do
      FactoryGirl.build(
        :c_user,
        id: '9d6831a4-39d1-11e5-9128-17e501c711a8')
    end

    before do
      allow(CUser).to receive(:new)
        .and_return(user)
    end

    it 'receives User.unfollow' do
      expect(user).to receive(:unfollow).with(target).once

      worker.perform(
        '4f16d362-a336-4b12-a133-4b8e39be7f8e',
        '9d6831a4-39d1-11e5-9128-17e501c711a8')
    end
  end
end
