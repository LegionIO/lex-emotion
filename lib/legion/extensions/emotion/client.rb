# frozen_string_literal: true

require 'legion/extensions/emotion/helpers/valence'
require 'legion/extensions/emotion/helpers/baseline'
require 'legion/extensions/emotion/helpers/momentum'
require 'legion/extensions/emotion/runners/valence'
require 'legion/extensions/emotion/runners/gut'

module Legion
  module Extensions
    module Emotion
      class Client
        include Runners::Valence
        include Runners::Gut

        def initialize(**)
          @emotion_baseline = Helpers::Baseline.new
          @emotion_momentum = Helpers::Momentum.new
          @domain_counts = Hash.new(0)
        end

        def track_domain(domain)
          @domain_counts[domain] += 1
        end

        private

        attr_reader :emotion_baseline, :emotion_momentum
      end
    end
  end
end
