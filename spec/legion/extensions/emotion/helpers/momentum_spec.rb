# frozen_string_literal: true

RSpec.describe Legion::Extensions::Emotion::Helpers::Momentum do
  let(:momentum) { described_class.new }
  let(:valence_mod) { Legion::Extensions::Emotion::Helpers::Valence }

  describe '#initialize' do
    it 'starts with zero state' do
      state = momentum.emotional_state
      expect(state[:arousal_ema]).to eq(0.0)
      expect(state[:stability]).to eq(1.0)
      expect(state[:history_size]).to eq(0)
    end
  end

  describe '#update' do
    it 'updates EMA toward current values' do
      v = valence_mod.new_valence(urgency: 0.8, importance: 0.7)
      result = momentum.update(v, 0.6)
      expect(result[:arousal_ema]).to be > 0.0
      expect(result[:valence_ema][:urgency]).to be > 0.0
    end

    it 'tracks history' do
      v = valence_mod.new_valence(urgency: 0.5)
      3.times { momentum.update(v, 0.5) }
      expect(momentum.emotional_state[:history_size]).to eq(3)
    end

    it 'caps history at 100' do
      v = valence_mod.new_valence
      105.times { momentum.update(v, 0.1) }
      expect(momentum.emotional_state[:history_size]).to eq(100)
    end

    it 'computes stability as inverse of emotional change' do
      v_calm = valence_mod.new_valence(urgency: 0.1)
      v_alarm = valence_mod.new_valence(urgency: 1.0, importance: 1.0, novelty: 1.0, familiarity: 1.0)

      momentum.update(v_calm, 0.1)
      result = momentum.update(v_alarm, 0.9)
      expect(result[:stability]).to be < 1.0
    end
  end
end
