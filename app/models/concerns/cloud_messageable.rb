# frozen_string_literal: true
# Tested with broadcast_fave_worker.rb
module CloudMessageable
  extend ActiveSupport::Concern

  def token_upkeep(unregistered, canonical)
    destroy_unregistered_token if unregistered
    update_canonical_token(canonical) if canonical
  end

  def destroy_unregistered_token
    Gcm.where(registration_token: @token).destroy_all
  end

  def update_canonical_token(canonical)
    gcm = Gcm.find(@token)
    gcm.update_attributes!(registration_token: canonical)
  end
end
