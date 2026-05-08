---
name: env-parity
description: >
  Compares environment configurations against the canonical baseline and
  identifies undocumented divergences. Use before promotions or during
  environment audits.
argument-hint: "[envs: dev,staging,production]"
allowed-tools: Read, Bash
---

Check environment parity: $ARGUMENTS

1. Invoke the `env-parity-checker` sub-agent
2. If divergences found:
   - Present each divergence with env, key, expected value, actual value
   - Block promotion until divergences are resolved or acknowledged
3. If no divergences: confirm parity and allow promotion

The `block-promotion-on-drift.sh` PreToolUse hook will block any deploy/promote/release
command if the parity report shows failures.

## Canonical Baseline

Define the baseline in your project's CLAUDE.md:

```markdown
## Environment Baseline
All environments must have these configuration keys:
- DATABASE_URL, REDIS_URL, API_BASE_URL
- AUTH_SECRET (different values per env, but key must exist)
- LOG_LEVEL: dev=debug, staging=info, production=warn
- RATE_LIMIT_RPM: dev=1000, staging=500, production=100
- FEATURE_FLAGS: must be identical across staging and production
```
