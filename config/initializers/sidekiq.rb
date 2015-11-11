Sidekiq.configure_server do |config|
  config.redis = { url: "redis://#{Figaro.env.redis_host!}:6379/0", namespace: 'hickory' }
  config.failures_max_count = 100000
end

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://#{Figaro.env.redis_host!}:6379/0", namespace: 'hickory' }
end
