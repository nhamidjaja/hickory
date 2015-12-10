Sidekiq.configure_server do |config|
  config.redis = { url: "redis://#{Figaro.env.redis_host!}:6379/0", namespace: 'hickory',
    password: Figaro.env.redis_password }
end
