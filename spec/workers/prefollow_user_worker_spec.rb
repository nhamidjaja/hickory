require 'rails_helper'

RSpec.describe PrefollowUserWorker do
  describe '.perform' do
    let(:worker) { PrefollowUserWorker.new }

    context 'no featured users' do
      before do
        allow(FeaturedUser).to receive(:all)
          .and_return([])
      end

      it do
        expect(FollowUserWorker)
          .to_not receive(:perform_async)

        worker.perform('user-id')
      end
    end

    context '1 featured user' do
      before do
        user = FactoryGirl.build(
          :user,
          id: '123e4567-e89b-12d3-a456-426655440000'
        )
        allow(FeaturedUser).to receive(:all)
          .and_return(
            [FactoryGirl.build(
              :featured_user,
              user: user
            )]
          )
      end

      it do
        expect(FollowUserWorker).to receive(:perform_async)
          .with('user-id', '123e4567-e89b-12d3-a456-426655440000').once

        worker.perform('user-id')
      end
    end

    context 'many featured users' do
      before do
        featured_list = FactoryGirl.build_list(:featured_user, 5)

        allow(FeaturedUser).to receive(:all)
          .and_return(featured_list)
      end

      it do
        expect(FollowUserWorker).to receive(:perform_async)
          .exactly(5).times

        worker.perform('user-id')
      end
    end
  end
end
