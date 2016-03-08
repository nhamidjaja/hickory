require 'rails_helper'

RSpec.describe CUserFave, type: :model do
  it { expect(FactoryGirl.build(:c_user_fave)).to be_valid }

  it do
    expect(FactoryGirl.build(
             :c_user_fave,
             c_user_id: nil))
      .to_not be_valid
  end

  it do
    expect(FactoryGirl.build(
             :c_user_fave,
             id: nil))
      .to_not be_valid
  end

  it do
    expect(FactoryGirl.build(
             :c_user_fave,
             content_url: ''))
      .to_not be_valid
  end

  it do
    expect(FactoryGirl.build(
             :c_user_fave,
             faved_at: nil))
      .to_not be_valid
  end

  describe '.counter' do
    let(:c_user) { FactoryGirl.build(:c_user,
      id: '4f16d362-a336-4b12-a133-4b8e39be7f8e') }
    let(:c_user_fave) { FactoryGirl.build(:c_user_fave,
      c_user: c_user,
      id: '123e4567-e89b-12d3-a456-426655440000') }
    let(:fave_counter) do
      FactoryGirl.build(:fave_counter,
        c_user: c_user,
        id: '123e4567-e89b-12d3-a456-426655440000',
        views: 23)
    end

    context 'unloaded' do
      before do
        c = double('FaveCounter')
        allow(FaveCounter).to receive(:consistency)
          .and_return(c)
        allow(c).to receive(:find_or_initialize_by)
          .with(c_user_id: Cequel.uuid('4f16d362-a336-4b12-a133-4b8e39be7f8e'),
            id: Cequel.uuid('123e4567-e89b-12d3-a456-426655440000'))
          .and_return(fave_counter)
      end

      it { expect(c_user_fave.counter.views).to eq(23) }
    end

    context 'preloaded' do
      before do
        c_user_fave.instance_variable_set('@counter', fave_counter)
        expect(CUserCounter).to_not receive(:find_or_initialize_by)
      end

      it { expect(c_user_fave.counter.views).to eq(23) }
    end
  end

  describe '.increment_view' do
    let(:fave) do
      FactoryGirl.build(:c_user_fave,
                        c_user_id: '123e4567-e89b-12d3-a456-426655440000',
                        id: 'de305d54-75b4-431b-adb2-eb6b9e546014')
    end
    let(:metal) { instance_double('Cequel::Metal::DataSet') }

    before do
      allow(Cequel::Metal::DataSet).to receive(:new).and_return(metal)
      allow(metal).to receive(:consistency).and_return(metal)
      allow(metal).to receive(:where).and_return(metal)
      allow(metal).to receive(:increment)
    end

    it 'increments views by 1' do
      expect(metal).to receive(:where)
        .with(
          c_user_id: Cequel.uuid('123e4567-e89b-12d3-a456-426655440000'),
          id: Cequel.uuid('de305d54-75b4-431b-adb2-eb6b9e546014'))
      expect(metal).to receive(:increment).with(views: 1)

      fave.increment_view
    end
  end
end
