# frozen_string_literal: true

module Legion
  module Extensions
    module Emotion
      module Helpers
        module Valence
          DIMENSIONS = %i[urgency importance novelty familiarity].freeze
          MAX_MAGNITUDE = Math.sqrt(4.0) # all 4 dimensions at 1.0

          # Attention modulation weights (from spec Section 6.1)
          URGENCY_ATTENTION_WEIGHT    = 0.4
          IMPORTANCE_ATTENTION_WEIGHT = 0.35
          NOVELTY_ATTENTION_WEIGHT    = 0.25
          ATTENTION_MULTIPLIER        = 0.3

          # Momentum
          MOMENTUM_ALPHA = 0.3

          # Source urgency map (spec Section 3.2)
          SOURCE_URGENCY = {
            firmware_violation: 1.0,
            human_direct:       0.9,
            mesh_priority:      0.7,
            scheduled:          0.4,
            ambient:            0.1
          }.freeze

          # Familiarity saturation (spec Section 3.5)
          FAMILIARITY_SATURATION = 100

          module_function

          def new_valence(urgency: 0.0, importance: 0.0, novelty: 0.0, familiarity: 0.0)
            {
              urgency:     clamp(urgency),
              importance:  clamp(importance),
              novelty:     clamp(novelty),
              familiarity: clamp(familiarity)
            }
          end

          def magnitude(valence)
            Math.sqrt(
              (valence[:urgency]**2) +
              (valence[:importance]**2) +
              (valence[:novelty]**2) +
              (valence[:familiarity]**2)
            )
          end

          def dominant_dimension(valence)
            DIMENSIONS.max_by { |d| valence[d] }
          end

          def aggregate(valences)
            return new_valence if valences.empty?

            sums = Hash.new(0.0)
            valences.each do |v|
              DIMENSIONS.each { |d| sums[d] += v[d] }
            end
            n = valences.size.to_f
            new_valence(**DIMENSIONS.to_h { |d| [d, sums[d] / n] })
          end

          def compute_arousal(valences)
            return 0.0 if valences.empty?

            total = valences.sum { |v| magnitude(v) }
            clamp(total / (valences.size * MAX_MAGNITUDE))
          end

          def modulate_salience(base_salience, valence)
            boost = ((valence[:urgency] * URGENCY_ATTENTION_WEIGHT) +
                     (valence[:importance] * IMPORTANCE_ATTENTION_WEIGHT) +
                     (valence[:novelty] * NOVELTY_ATTENTION_WEIGHT)) * ATTENTION_MULTIPLIER
            clamp(base_salience + boost)
          end

          def clamp(value, min = 0.0, max = 1.0)
            value.clamp(min, max)
          end
        end
      end
    end
  end
end
