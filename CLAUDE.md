# lex-emotion

**Level 3 Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Grandparent**: `/Users/miverso2/rubymine/legion/CLAUDE.md`

## Purpose

Multi-dimensional emotional valence system for the LegionIO cognitive architecture. Implements four-dimensional valence vectors, arousal computation, attention modulation, gut instinct signal derivation, and exponential moving average momentum tracking.

## Gem Info

- **Gem name**: `lex-emotion`
- **Version**: `0.1.0`
- **Module**: `Legion::Extensions::Emotion`
- **Ruby**: `>= 3.4`
- **License**: MIT

## File Structure

```
lib/legion/extensions/emotion/
  version.rb
  helpers/
    valence.rb    # DIMENSIONS, constants, new_valence, magnitude, aggregate, compute_arousal, modulate_salience
    baseline.rb   # Baseline class - running stats per dimension for normalization
    momentum.rb   # Momentum class - EMA over valence/arousal, stability tracking
  runners/
    valence.rb    # evaluate_valence, aggregate_valences, modulate_attention, compute_arousal
    gut.rb        # gut_instinct, emotional_state, decay_momentum
  actors/
    momentum_decay.rb  # MomentumDecay - Every 60s, drifts momentum toward neutral
spec/
  legion/extensions/emotion/
    helpers/
      valence_spec.rb
      baseline_spec.rb
      momentum_spec.rb
    runners/
      valence_spec.rb
      gut_spec.rb
    client_spec.rb
```

## Key Constants (Helpers::Valence)

```ruby
DIMENSIONS                  = %i[urgency importance novelty familiarity]
URGENCY_ATTENTION_WEIGHT    = 0.4
IMPORTANCE_ATTENTION_WEIGHT = 0.35
NOVELTY_ATTENTION_WEIGHT    = 0.25
ATTENTION_MULTIPLIER        = 0.3
MOMENTUM_ALPHA              = 0.3
FAMILIARITY_SATURATION      = 100  # signals before familiarity saturates at 1.0
SOURCE_URGENCY = {
  firmware_violation: 1.0,
  human_direct:       0.9,
  mesh_priority:      0.7,
  scheduled:          0.4,
  ambient:            0.1
}
```

## Gut Instinct Signal Logic

In `Runners::Gut#determine_signal`:
- `urgency > 0.7 && importance > 0.7` -> `:alarm`
- `arousal > 0.7` -> `:heightened`
- `novelty > 0.7 && familiarity < 0.3` -> `:explore`
- `importance > 0.6` -> `:attend`
- `arousal < 0.2` -> `:calm`
- else -> `:neutral`

Confidence combines consensus among valence magnitudes (60%) and memory evidence count (40%).

## evaluate_valence Internals

`Runners::Valence#evaluate_valence` computes four raw scores then normalizes each against the running baseline (Z-score-like normalization via `Helpers::Baseline`). After normalization, it also updates the baseline for each dimension with the raw score. This means the baseline adapts over time.

Urgency computation combines: deadline urgency (50%), source type (30%), signal hint (20%).
Importance computation combines: domain weight (30%), impact scope (20%), irreversibility (25%), outcome severity (25%).

## Baseline Class

`Helpers::Baseline` tracks per-dimension running mean and standard deviation using exponential moving average. `normalize(raw, dimension)` returns the Z-score clamped to `[0, 1]`, so values within 1 stddev of the mean return ~0.5.

## Actors

| Actor | Interval | Runner | Method | Purpose |
|---|---|---|---|---|
| `MomentumDecay` | Every 60s | `Runners::Gut` | `decay_momentum` | Drifts emotional momentum toward neutral valence |

### MomentumDecay

Periodically nudges the `Helpers::Momentum` EMA toward a neutral valence vector (`urgency: 0.5, importance: 0.5, novelty: 0.5, familiarity: 0.5`) with a neutral arousal of `0.5`. This prevents momentum from being permanently stuck at an extreme emotional state after an intense event. Returns `{ decayed: true, stability: Float }`.

## Integration Points

- **lex-tick**: `emotional_evaluation` phase calls `evaluate_valence`; `gut_instinct` phase calls `gut_instinct`
- **lex-memory**: `emotional_intensity` from valence magnitude modulates trace decay
- **lex-prediction**: emotional state context influences prediction confidence

## Development Notes

- `@domain_counts` in `Runners::Valence` is not explicitly initialized; `compute_familiarity` handles nil safely with `&.fetch`
- `Momentum#update` keeps last 100 history entries; `stability` = `1.0 - |delta_magnitude|`
- `MAX_MAGNITUDE = Math.sqrt(4.0)` — used to normalize arousal to `[0, 1]`
- `decay_momentum` calls `emotion_momentum.update(neutral, 0.5)` — the private memoized `@emotion_momentum` helper shared with `gut_instinct`; the actor runs without a task or subtask (`use_runner?: false`, `generate_task?: false`)
