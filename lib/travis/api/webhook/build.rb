module Travis
  module Api
    module Webhook
      class Build
        require 'travis/api/webhook/build/finished'

        attr_reader :build, :commit, :request, :repository, :options

        def initialize(build, options = {})
          @build = build
          @commit = build.commit
          @request = build.request
          @repository = build.repository
          @options = options
        end

        private

        def build_url
          ["https://#{Travis.config.host}", repository.slug, 'builds', build.id].join('/')
        end
      end
    end
  end
end
