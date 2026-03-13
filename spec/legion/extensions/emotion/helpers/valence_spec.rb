# frozen_string_literal: true

RSpec.describe Legion::Extensions::Emotion::Helpers::Valence do
  describe '.new_valence' do
    it 'creates a valence with defaults' do
      v = described_class.new_valence
      expect(v[:urgency]).to eq(0.0)
      expect(v[:importance]).to eq(0.0)
      expect(v[:novelty]).to eq(0.0)
      expect(v[:familiarity]).to eq(0.0)
    end

    it 'creates a valence with custom values' do
      v = described_class.new_valence(urgency: 0.8, importance: 0.6)
      expect(v[:urgency]).to eq(0.8)
      expect(v[:importance]).to eq(0.6)
    end

    it 'clamps values to [0, 1]' do
      v = described_class.new_valence(urgency: 1.5, novelty: -0.3)
      expect(v[:urgency]).to eq(1.0)
      expect(v[:novelty]).to eq(0.0)
    end
  end

  describe '.magnitude' do
    it 'computes zero for zero valence' do
      v = described_class.new_valence
      expect(described_class.magnitude(v)).to eq(0.0)
    end

    it 'computes sqrt(4) for all-ones valence' do
      v = described_class.new_valence(urgency: 1.0, importance: 1.0, novelty: 1.0, familiarity: 1.0)
      expect(described_class.magnitude(v)).to be_within(0.001).of(2.0)
    end
  end

  describe '.dominant_dimension' do
    it 'returns the highest dimension' do
      v = described_class.new_valence(urgency: 0.2, importance: 0.9, novelty: 0.1, familiarity: 0.3)
      expect(described_class.dominant_dimension(v)).to eq(:importance)
    end
  end

  describe '.aggregate' do
    it 'returns zero valence for empty array' do
      result = described_class.aggregate([])
      expect(result[:urgency]).to eq(0.0)
    end

    it 'averages multiple valences' do
      v1 = described_class.new_valence(urgency: 0.8, importance: 0.2)
      v2 = described_class.new_valence(urgency: 0.4, importance: 0.6)
      result = described_class.aggregate([v1, v2])
      expect(result[:urgency]).to be_within(0.001).of(0.6)
      expect(result[:importance]).to be_within(0.001).of(0.4)
    end
  end

  describe '.compute_arousal' do
    it 'returns 0 for empty valences' do
      expect(described_class.compute_arousal([])).to eq(0.0)
    end

    it 'returns 1.0 for all-max valences' do
      v = described_class.new_valence(urgency: 1.0, importance: 1.0, novelty: 1.0, familiarity: 1.0)
      expect(described_class.compute_arousal([v])).to be_within(0.001).of(1.0)
    end

    it 'returns moderate arousal for mixed valences' do
      v = described_class.new_valence(urgency: 0.5, importance: 0.5)
      arousal = described_class.compute_arousal([v])
      expect(arousal).to be > 0.0
      expect(arousal).to be < 1.0
    end
  end

  describe '.modulate_salience' do
    it 'boosts salience based on valence' do
      v = described_class.new_valence(urgency: 0.8, importance: 0.6, novelty: 0.4)
      modulated = described_class.modulate_salience(0.5, v)
      expect(modulated).to be > 0.5
    end

    it 'clamps at 1.0' do
      v = described_class.new_valence(urgency: 1.0, importance: 1.0, novelty: 1.0)
      modulated = described_class.modulate_salience(0.9, v)
      expect(modulated).to eq(1.0)
    end
  end
end
