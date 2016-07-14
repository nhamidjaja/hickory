# frozen_string_literal: true
require 'rails_helper'

RSpec.describe OpenStory, type: :model do
  it { expect(FactoryGirl.build(:open_story)).to be_valid }

  it do
    expect(FactoryGirl.build(:open_story,
                             faver_id: nil)).to_not be_valid
  end
  it do
    expect(FactoryGirl.build(:open_story, content_url: nil))
      .to_not be_valid
  end
  it do
    expect(FactoryGirl.build(:open_story, faved_at: nil))
      .to_not be_valid
  end

  describe '.counter' do
    let(:c_user) do
      FactoryGirl.build(:c_user,
                        id: '4f16d362-a336-4b12-a133-4b8e39be7f8e')
    end
    let(:story) do
      FactoryGirl.build(:open_story,
                        id: '123e4567-e89b-12d3-a456-426655440000',
                        faver_id: '5fa565e3-79ab-4e66-8e6f-3e4d9e343427')
    end
    let(:fave_counter) do
      FactoryGirl.build(:fave_counter,
                        c_user: c_user,
                        id: story.id,
                        views: 23)
    end

    context 'unloaded' do
      before do
        c = double('FaveCounter')
        allow(FaveCounter).to receive(:consistency)
          .and_return(c)
        allow(c).to receive(:find_or_initialize_by)
          .with(c_user_id: story.faver_id,
                id: story.id)
          .and_return(fave_counter)
      end

      it { expect(story.counter.views).to eq(23) }
    end

    context 'preloaded' do
      before do
        story.instance_variable_set('@counter', fave_counter)
        expect(CUserCounter).to_not receive(:find_or_initialize_by)
      end

      it { expect(story.counter.views).to eq(23) }
    end
  end

  describe '.faver' do
    let(:story) do
      FactoryGirl.build(:open_story,
                        faver_id: '5fa565e3-79ab-4e66-8e6f-3e4d9e343427')
    end

    it 'finds User' do
      expect(User).to receive(:find).with(
        '5fa565e3-79ab-4e66-8e6f-3e4d9e343427'
      )

      story.faver
    end
  end
end
