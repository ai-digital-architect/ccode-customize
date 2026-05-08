---
name: contract-test
description: >
  Generates API consumer contracts from frontend code and verifies them
  against backend implementation. Detects API drift. Use before releases
  or after API changes.
argument-hint: "[api-module or 'all']"
allowed-tools: Read, Bash
---

Run contract testing: $ARGUMENTS

## Steps

1. Invoke `contract-extractor` to scan frontend API usage and generate contracts
   - Output: `.claude/contracts/consumer-contracts.json`
2. Invoke `contract-verifier` to check backend endpoints against those contracts
   - Output: `.claude/contracts/verification.json`
3. If drift detected: report mismatches with file/line references
4. If no drift: confirm all contracts are satisfied
