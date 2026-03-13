# frozen_string_literal: true

module Legion
  module Extensions
    module Emotion
      module Helpers
        class Momentum
          attr_reader :valence_ema, :arousal_ema, :stability, :history

          def initialize
            @valence_ema = Valence.new_valence
            @arousal_ema = 0.0
            @stability = 1.0
            @history = []
          end

          def update(current_valence, current_arousal)
            alpha = Valence::MOMENTUM_ALPHA

            previous_aggregate = Valence.magnitude(@valence_ema)
            current_aggregate = Valence.magnitude(current_valence)

            @valence_ema = Valence::DIMENSIONS.to_h do |dim|
              [dim, (alpha * current_valence[dim]) + ((1.0 - alpha) * @valence_ema[dim])]
            end

            @arousal_ema = (alpha * current_arousal) + ((1.0 - alpha) * @arousal_ema)
            @stability = Valence.clamp(1.0 - (current_aggregate - previous_aggregate).abs)

            @history << { valence: current_valence, arousal: current_arousal, timestamp: Time.now.utc }
            @history.shift while @history.size > 100

            { valence_ema: @valence_ema, arousal_ema: @arousal_ema, stability: @stability }
          end

          def emotional_state
            {
              valence_ema: @valence_ema,
              arousal_ema: @arousal_ema,
              stability:   @stability,
              history_size: @history.size
            }
          end
        end
      end
    end
  end
end
