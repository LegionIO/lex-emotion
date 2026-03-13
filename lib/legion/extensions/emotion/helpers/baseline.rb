# frozen_string_literal: true

module Legion
  module Extensions
    module Emotion
      module Helpers
        class Baseline
          ALPHA = 0.05       # slow adaptation to prevent adversarial manipulation
          MIN_STDDEV = 0.1   # prevents division issues when baseline is stable
          INITIAL_MEAN = 0.5
          INITIAL_STDDEV = 0.25

          attr_reader :dimensions

          def initialize
            @dimensions = Valence::DIMENSIONS.to_h do |dim|
              [dim, { mean: INITIAL_MEAN, stddev: INITIAL_STDDEV, count: 0 }]
            end
          end

          def normalize(raw_score, dimension)
            baseline = @dimensions[dimension]
            return Valence.clamp(raw_score) unless baseline

            normalized = (raw_score - baseline[:mean]) / [baseline[:stddev], MIN_STDDEV].max
            Valence.clamp(normalized)
          end

          def update(dimension, raw_score)
            baseline = @dimensions[dimension]
            return unless baseline

            baseline[:count] += 1
            old_mean = baseline[:mean]
            baseline[:mean] = (ALPHA * raw_score) + ((1.0 - ALPHA) * old_mean)
            # Online stddev update (Welford-like with EMA)
            deviation = (raw_score - baseline[:mean]).abs
            baseline[:stddev] = (ALPHA * deviation) + ((1.0 - ALPHA) * baseline[:stddev])
          end

          def get(dimension)
            @dimensions[dimension]
          end
        end
      end
    end
  end
end
