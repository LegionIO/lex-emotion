# frozen_string_literal: true

module Legion
  module Extensions
    module Emotion
      module Runners
        module Gut
          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex)

          def gut_instinct(valences:, memory_signals: [], confidence_threshold: 0.5, **)
            return { signal: :neutral, confidence: 0.0, basis: :insufficient_data } if valences.empty?

            arousal = Helpers::Valence.compute_arousal(valences)
            aggregate = Helpers::Valence.aggregate(valences)
            dominant = Helpers::Valence.dominant_dimension(aggregate)

            # Gut instinct is the compressed parallel query of full memory + emotional state
            # High arousal + high importance = caution signal
            # High novelty + low familiarity = exploration signal
            # High urgency + high importance = alarm signal
            signal = determine_signal(aggregate, arousal)
            confidence = compute_confidence(valences, memory_signals)

            result = {
              signal:     signal,
              confidence: confidence,
              arousal:    arousal,
              dominant:   dominant,
              aggregate:  aggregate,
              reliable:   confidence >= confidence_threshold
            }

            # Update momentum if available
            emotion_momentum.update(aggregate, arousal) if respond_to?(:emotion_momentum, true)

            result
          end

          def emotional_state(**)
            momentum = emotion_momentum
            {
              momentum:  momentum.emotional_state,
              baseline:  emotion_baseline.dimensions
            }
          end

          private

          def emotion_momentum
            @emotion_momentum ||= Helpers::Momentum.new
          end

          def determine_signal(aggregate, arousal)
            if aggregate[:urgency] > 0.7 && aggregate[:importance] > 0.7
              :alarm
            elsif arousal > 0.7
              :heightened
            elsif aggregate[:novelty] > 0.7 && aggregate[:familiarity] < 0.3
              :explore
            elsif aggregate[:importance] > 0.6
              :attend
            elsif arousal < 0.2
              :calm
            else
              :neutral
            end
          end

          def compute_confidence(valences, memory_signals)
            return 0.0 if valences.empty?

            # Confidence based on consensus among valences and memory evidence
            magnitudes = valences.map { |v| Helpers::Valence.magnitude(v) }
            mean_mag = magnitudes.sum / magnitudes.size
            variance = magnitudes.sum { |m| (m - mean_mag)**2 } / magnitudes.size

            consensus = Helpers::Valence.clamp(1.0 - Math.sqrt(variance))
            evidence = Helpers::Valence.clamp(memory_signals.size / 10.0)

            (consensus * 0.6) + (evidence * 0.4)
          end
        end
      end
    end
  end
end
