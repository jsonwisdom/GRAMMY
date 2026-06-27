# Deezerbot Resolver Spec

## Purpose

The resolver validates Proof-of-Fan receipts and routes weighted contribution into the discovery ledger.

## Inputs

Schema:

```txt
ProofOfFan(bytes32 trackId,address fan,uint8 actionType,uint256 timestamp,bytes32 nonce)
```

## Action Weights

```txt
0 = listen     => 1
1 = save/share => 5
2 = remix/tip  => 20
```

## Required State

```txt
used_nonce[nonce] = true/false
total_weighted[trackId] = uint256
milestone_threshold = 100
```

## Attestation Rules

1. Reject zero-address fan.
2. Reject already-used nonce.
3. Reject unknown actionType.
4. Mark nonce used before external routing.
5. Add action weight to total track score.
6. Emit receipt-routed event.
7. When total track score crosses milestone, release discovery reward to eligible early fans.

## Security Rules

- Production caller should be restricted to the EAS resolver path.
- Nonce uniqueness is mandatory.
- Split maps should be immutable per track.
- Discovery Pool release must be idempotent per milestone.
- Indexer must reject timestamp drift and impossible velocity.

## Execution Record

```txt
schema_uid=
resolver_contract=
split_factory=
discovery_pool=
first_test_attestation_uid=
first_test_attestation_tx=
```

## Verdict Gate

Gold verdict only after:

- schema UID exists
- resolver address exists
- 10 test attestations pass with unique nonce values
- duplicate nonce test fails
- milestone release test passes once and cannot double-release
