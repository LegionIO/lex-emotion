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

            signal = determine_signal(aggregate, arousal)
            confidence = compute_confidence(valences, memory_signals)

            Legion::Logging.debug "[emotion] gut instinct: signal=#{signal} confidence=#{confidence.round(2)} " \
                                  "arousal=#{arousal.round(2)} dominant=#{dominant} reliable=#{confidence >= confidence_threshold}"

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

          def decay_momentum(**)
            neutral = { urgency: 0.5, importance: 0.5, novelty: 0.5, familiarity: 0.5 }
            momentum = emotion_momentum
            momentum.update(neutral, 0.5)
            stability = momentum.stability

            Legion::Logging.debug "[emotion] momentum decay: stability=#{stability.round(2)}"

            { decayed: true, stability: stability }
          end

          def emotional_state(**)
            momentum = emotion_momentum
            state = momentum.emotional_state
            Legion::Logging.debug "[emotion] state query: stability=#{state[:stability]&.round(2)}"
            {
              momentum: state,
              baseline: emotion_baseline.dimensions
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
