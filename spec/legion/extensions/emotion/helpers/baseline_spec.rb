# frozen_string_literal: true

RSpec.describe Legion::Extensions::Emotion::Helpers::Baseline do
  let(:baseline) { described_class.new }

  describe '#initialize' do
    it 'sets initial values for all dimensions' do
      Legion::Extensions::Emotion::Helpers::Valence::DIMENSIONS.each do |dim|
        state = baseline.get(dim)
        expect(state[:mean]).to eq(0.5)
        expect(state[:stddev]).to eq(0.25)
        expect(state[:count]).to eq(0)
      end
    end
  end

  describe '#normalize' do
    it 'normalizes a raw score against baseline' do
      result = baseline.normalize(0.5, :urgency)
      expect(result).to be_between(0.0, 1.0)
    end

    it 'returns higher value for scores above mean' do
      low = baseline.normalize(0.3, :urgency)
      high = baseline.normalize(0.9, :urgency)
      expect(high).to be > low
    end
  end

  describe '#update' do
    it 'shifts mean toward observed values' do
      original_mean = baseline.get(:urgency)[:mean]
      10.times { baseline.update(:urgency, 0.9) }
      expect(baseline.get(:urgency)[:mean]).to be > original_mean
    end

    it 'increments count' do
      3.times { baseline.update(:importance, 0.5) }
      expect(baseline.get(:importance)[:count]).to eq(3)
    end

    it 'adapts slowly (alpha=0.05)' do
      baseline.update(:urgency, 1.0)
      # After one update, mean should barely move: 0.05*1.0 + 0.95*0.5 = 0.525
      expect(baseline.get(:urgency)[:mean]).to be_within(0.001).of(0.525)
    end
  end
end
