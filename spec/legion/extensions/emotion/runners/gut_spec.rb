# frozen_string_literal: true

require 'legion/extensions/emotion/client'

RSpec.describe Legion::Extensions::Emotion::Runners::Gut do
  let(:client) { Legion::Extensions::Emotion::Client.new }
  let(:valence_mod) { Legion::Extensions::Emotion::Helpers::Valence }

  describe '#gut_instinct' do
    it 'returns neutral for empty valences' do
      result = client.gut_instinct(valences: [])
      expect(result[:signal]).to eq(:neutral)
      expect(result[:confidence]).to eq(0.0)
    end

    it 'returns alarm for high urgency + importance' do
      v = valence_mod.new_valence(urgency: 0.9, importance: 0.9, novelty: 0.5, familiarity: 0.5)
      result = client.gut_instinct(valences: [v])
      expect(result[:signal]).to eq(:alarm)
    end

    it 'returns explore for high novelty + low familiarity' do
      v = valence_mod.new_valence(urgency: 0.2, importance: 0.2, novelty: 0.9, familiarity: 0.1)
      result = client.gut_instinct(valences: [v])
      expect(result[:signal]).to eq(:explore)
    end

    it 'returns calm for low arousal' do
      v = valence_mod.new_valence(urgency: 0.05, importance: 0.05, novelty: 0.05, familiarity: 0.05)
      result = client.gut_instinct(valences: [v])
      expect(result[:signal]).to eq(:calm)
    end

    it 'includes confidence and reliability' do
      v = valence_mod.new_valence(urgency: 0.5)
      result = client.gut_instinct(valences: [v], memory_signals: [1, 2, 3])
      expect(result).to have_key(:confidence)
      expect(result).to have_key(:reliable)
    end

    it 'increases confidence with more memory evidence' do
      v = valence_mod.new_valence(urgency: 0.5)
      low_evidence = client.gut_instinct(valences: [v], memory_signals: [])
      high_evidence = client.gut_instinct(valences: [v], memory_signals: Array.new(10, 1))
      expect(high_evidence[:confidence]).to be >= low_evidence[:confidence]
    end
  end

  describe '#emotional_state' do
    it 'returns momentum and baseline state' do
      state = client.emotional_state
      expect(state).to have_key(:momentum)
      expect(state).to have_key(:baseline)
    end
  end

  describe '#decay_momentum' do
    it 'returns decayed: true' do
      result = client.decay_momentum
      expect(result[:decayed]).to be true
    end

    it 'returns a Float stability value' do
      result = client.decay_momentum
      expect(result[:stability]).to be_a(Float)
    end

    it 'returns stability within [0.0, 1.0]' do
      result = client.decay_momentum
      expect(result[:stability]).to be_between(0.0, 1.0)
    end
  end
end
