# frozen_string_literal: true
# User representation in cassandra
class CUser
  include Cequel::Record

  key :id, :uuid

  has_many :c_user_faves, class_name: 'CUserFave'
  has_many :c_user_fave_urls
  has_many :followings
  has_many :followers
  has_many :c_user_counters
  has_many :stories
  has_many :friends

  validates :id, presence: true

  def fave(content, faved_at)
    fave = save_faves(content, faved_at)

    increment_faves_counter

    fave
  end

  def follow(target)
    already_following = following?(target)

    followings.new(id: target.id).save!
    target.followers.new(id: id).save!
    friends.where(id: target.id).destroy_all

    increment_follow_counters(target) unless already_following
  end

  def unfollow(target)
    already_following = following?(target)

    followings.where(id: target.id).delete_all
    target.followers.where(id: id).delete_all

    decrement_follow_counters(target) if already_following
  end

  def following?(target)
    followings.where(id: target.id).any?
  end

  private

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def save_faves(content, faved_at)
    fave_id = Cequel.uuid(faved_at)

    stories.new(
      id: fave_id,
      faver_id: id,
      content_url: content.url,
      title: content.title,
      image_url: content.image_url,
      published_at: content.published_at,
      faved_at: faved_at
    ).save!(consistency: :any)

    c_user_fave_urls.new(
      content_url: content.url,
      id: fave_id,
      faved_at: faved_at
    ).save!(consistency: :any)

    c_user_faves.new(
      id: fave_id,
      content_url: content.url,
      title: content.title,
      image_url: content.image_url,
      published_at: content.published_at,
      faved_at: faved_at
    ).save!(consistency: :any)
  end

  def increment_faves_counter
    counter = Cequel::Metal::DataSet
              .new(:c_user_counters, CUserCounter.connection)
              .consistency(:one)
    counter.where(c_user_id: Cequel.uuid(id)).increment(faves: 1)
  end

  def increment_follow_counters(target)
    counter = Cequel::Metal::DataSet
              .new(:c_user_counters, CUserCounter.connection)
              .consistency(:one)

    counter.where(c_user_id: id).increment(followings: 1)
    counter.where(c_user_id: target.id)
           .increment(followers: 1)
  end

  def decrement_follow_counters(target)
    counter = Cequel::Metal::DataSet
              .new(:c_user_counters, CUserCounter.connection)
              .consistency(:one)

    counter.where(c_user_id: id).decrement(followings: 1)
    counter.where(c_user_id: target.id)
           .decrement(followers: 1)
  end
end
