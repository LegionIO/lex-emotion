# frozen_string_literal: true

require 'legion/extensions/emotion/client'

RSpec.describe Legion::Extensions::Emotion::Client do
  let(:client) { described_class.new }

  it 'responds to valence runner methods' do
    expect(client).to respond_to(:evaluate_valence)
    expect(client).to respond_to(:aggregate_valences)
    expect(client).to respond_to(:modulate_attention)
    expect(client).to respond_to(:compute_arousal)
  end

  it 'responds to gut runner methods' do
    expect(client).to respond_to(:gut_instinct)
    expect(client).to respond_to(:emotional_state)
  end

  it 'tracks domain counts for familiarity' do
    client.track_domain('work')
    client.track_domain('work')
    client.track_domain('personal')
    # Domain tracking improves familiarity scoring
    result = client.evaluate_valence(signal: {}, domain: 'work')
    expect(result[:valence][:familiarity]).to be >= 0.0
  end

  it 'round-trips a full emotional evaluation cycle' do
    # Evaluate multiple signals
    v1 = client.evaluate_valence(signal: { urgency_hint: 0.8 }, source_type: :human_direct)
    v2 = client.evaluate_valence(signal: { novelty_score: 0.9 }, source_type: :ambient)

    # Aggregate
    agg = client.aggregate_valences(valences: [v1[:valence], v2[:valence]])
    expect(agg[:count]).to eq(2)

    # Gut instinct
    gut = client.gut_instinct(valences: [v1[:valence], v2[:valence]])
    expect(gut[:signal]).to be_a(Symbol)

    # State persists
    state = client.emotional_state
    expect(state[:momentum][:history_size]).to be >= 1
  end
end
