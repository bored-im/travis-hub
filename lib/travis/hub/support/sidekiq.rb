require 'sidekiq'
require 'travis/exceptions/sidekiq'
require 'travis/metrics/sidekiq'
require 'travis/hub/support/sidekiq/honeycomb'
require 'travis/hub/support/sidekiq/log_format'
require 'travis/hub/support/sidekiq/marginalia'

module Travis
  module Sidekiq
    def setup(config)
      ::Sidekiq::Logging.logger.level = Logger::WARN

      ::Sidekiq.configure_server do |c|
        c.redis = {
          url: config.redis.url,
          namespace: config.sidekiq.namespace
        }

        c.server_middleware do |chain|
          chain.add Travis::Exceptions::Sidekiq if config.sentry && config.sentry.dsn
          chain.add Travis::Metrics::Sidekiq
          chain.add Travis::Hub::Sidekiq::Marginalia, app: 'hub'
          chain.add Travis::Hub::Sidekiq::Honeycomb
        end

        c.logger.formatter = Support::Sidekiq::Logging.new(config.logger || {})
      end

      ::Sidekiq.configure_client do |c|
        c.redis = {
          url: config.redis.url,
          namespace: config.sidekiq.namespace
        }
      end
    end

    extend self
  end
end
