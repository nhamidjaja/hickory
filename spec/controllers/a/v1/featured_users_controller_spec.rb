# frozen_string_literal: true
require 'rails_helper'

RSpec.describe A::V1::FeaturedUsersController, type: :controller do
  describe 'GET #index' do
    let(:featured_users) { double }
    before do
      joins = double
      allow(User).to receive(:joins).and_return(joins)
      allow(joins).to receive(:order).and_return(featured_users)
    end

    context 'when anonymous' do
      context 'no featured user' do
        before do
          allow(featured_users).to receive(:limit).and_return([])
        end

        it 'is empty' do
          get :index

          expect(assigns(:featured_users)).to be_empty
        end
      end

      context 'many featured users' do
        before do
          allow(featured_users).to receive(:limit)
            .and_return(FactoryGirl.build_list(:user, 7))
        end

        it 'has assigned array' do
          get :index

          expect(assigns(:featured_users)).to_not be_empty
        end
      end
    end

    context 'signed in user' do
      login_user

      context 'not following any featured users' do
        before do
          allow(featured_users).to receive(:limit)
            .and_return(FactoryGirl.build_list(:user, 3))
        end

        it 'does not filter' do
          get :index

          expect(assigns(:featured_users).size).to eq(3)
        end
      end

      # context 'following a featured user' do
      #   before do
      #     following = FactoryGirl.build(
      # :user,
      # id: '4f16d362-a336-4b12-a133-4b8e39be7f8e')
      #     c_user = instance_double('CUser')
      #     allow(current_user).to receive(:in_cassandra)
      #       .and_return(c_user)
      #     expect(c_user).to receive(:following?).with(following)
      #       .and_return(true)

      #     list = FactoryGirl.build_list(:user, 2)
      #     list.append(following)

      #     allow(featured_users).to receive(:limit)
      #       .and_return(list)
      #   end

      #   it 'filters already followed users' do
      #     get :index

      #     expect(assigns(:featured_users).size).to eq(2)
      #   end
      # end
    end
  end
end
