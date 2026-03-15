# lex-emotion

Multi-dimensional emotional valence system for brain-modeled agentic AI. Models emotional state across four dimensions, computes arousal and gut instinct signals, and modulates attention.

## Overview

`lex-emotion` implements the agent's affective layer. Emotional state is not a single scalar — it is a four-dimensional valence vector. Valence influences memory decay rates, attention allocation, and gut instinct signals. Momentum (exponential moving average) smooths emotional state over time.

## Valence Dimensions

| Dimension | Description |
|-----------|-------------|
| `urgency` | Time pressure and immediacy |
| `importance` | Impact scope and outcome severity |
| `novelty` | Degree of unexpectedness |
| `familiarity` | How well-known the domain/source is |

All dimensions are clamped to `[0.0, 1.0]`.

## Source Urgency Defaults

| Source Type | Urgency Weight |
|-------------|---------------|
| `firmware_violation` | 1.0 |
| `human_direct` | 0.9 |
| `mesh_priority` | 0.7 |
| `scheduled` | 0.4 |
| `ambient` | 0.1 |

## Installation

Add to your Gemfile:

```ruby
gem 'lex-emotion'
```

## Usage

### Evaluating Valence

```ruby
require 'legion/extensions/emotion'

# Evaluate a signal's emotional valence
result = Legion::Extensions::Emotion::Runners::Valence.evaluate_valence(
  signal: { urgency_hint: 0.8, domain_weight: 0.9, impact_scope: 0.6,
            reversibility: 0.2, outcome_severity: 0.8 },
  source_type: :human_direct,
  deadline: Time.now.utc + 3600
)

result[:valence]            # => { urgency: 0.72, importance: 0.68, novelty: 0.5, familiarity: 0.0 }
result[:magnitude]          # => 1.09 (Euclidean norm)
result[:dominant_dimension] # => :urgency
```

### Aggregating Multiple Valences

```ruby
valences = [
  { urgency: 0.8, importance: 0.7, novelty: 0.4, familiarity: 0.3 },
  { urgency: 0.5, importance: 0.9, novelty: 0.2, familiarity: 0.6 }
]

Legion::Extensions::Emotion::Runners::Valence.aggregate_valences(valences: valences)
# => { aggregate: {...}, arousal: 0.65, dominant: :importance, count: 2 }
```

### Gut Instinct

```ruby
# Compressed parallel query — returns a signal classification
result = Legion::Extensions::Emotion::Runners::Gut.gut_instinct(
  valences: valences,
  memory_signals: [1, 2, 3],
  confidence_threshold: 0.5
)

result[:signal]     # => :alarm | :heightened | :explore | :attend | :calm | :neutral
result[:confidence] # => 0.0..1.0
result[:reliable]   # => true/false
```

### Current Emotional State

```ruby
Legion::Extensions::Emotion::Runners::Gut.emotional_state
# => { momentum: { valence_ema: {...}, arousal_ema: 0.4, stability: 0.9, history_size: 5 },
#      baseline: { urgency: {...}, ... } }
```

### Attention Modulation

```ruby
Legion::Extensions::Emotion::Runners::Valence.modulate_attention(
  base_salience: 0.5,
  valence: { urgency: 0.8, importance: 0.7, novelty: 0.3, familiarity: 0.5 }
)
# => { original: 0.5, modulated: 0.72, boost: 0.22 }
```

## Momentum

Emotional momentum is an exponential moving average (alpha = 0.3) over valence and arousal. It tracks `valence_ema`, `arousal_ema`, `stability`, and last 100 data points.

## Actors

| Actor | Interval | Description |
|-------|----------|-------------|
| `MomentumDecay` | Every 60s | Periodically drifts emotional momentum toward neutral valence via exponential decay, preventing permanent extreme states |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
