# Deezerbot Gold Gate Test Framework

## Status

`VERIFIED_PENDING`

The repo now separates desired state from realized state:

- Desired state: schema, resolver behavior, tests, deployment plan
- Realized state: Base EAS schema UID, resolver address, registration transaction, first attestation UID

No gold verdict until realized state exists and tests pass.

## Test Target

Schema:

```txt
ProofOfFan(bytes32 trackId,address fan,uint8 actionType,uint256 timestamp,bytes32 nonce)
```

## Required Gold Gate Tests

### 1. Ten Unique Nonce Attestations Pass

Input:

```txt
trackId = keccak256(canonical_track_metadata_cid)
fan[0..9] = unique or repeated valid wallet addresses
nonce[0..9] = unique bytes32 values
actionType = valid values only: 0, 1, 2
```

Expected:

```txt
all 10 attestations accepted
used_nonce[nonce] = true for each nonce
total_weighted[trackId] increases deterministically
receipt routed event emitted for each attestation
```

### 2. Duplicate Nonce Fails

Input:

```txt
same trackId
same fan
same nonce already used
```

Expected:

```txt
attestation rejected
used_nonce state unchanged
total_weighted unchanged
no payout routing
no discovery release
```

### 3. Invalid Action Type Fails

Input:

```txt
actionType = 3 or greater
```

Expected:

```txt
attestation rejected
total_weighted unchanged
nonce should not be consumed if validation fails before nonce lock
```

### 4. Zero Address Fan Fails

Input:

```txt
fan = 0x0000000000000000000000000000000000000000
```

Expected:

```txt
attestation rejected
nonce not consumed
total_weighted unchanged
```

### 5. Milestone Release Happens Once

Input:

```txt
weighted actions cross milestone_threshold
```

Expected:

```txt
discovery pool release executes once
milestone_locked[trackId][milestone] = true
replaying more attestations above same milestone cannot double-release same pool epoch
```

### 6. Timestamp Drift Rejected By Indexer

Input:

```txt
timestamp far future or impossible historical drift
```

Expected:

```txt
onchain resolver may accept minimal payload
indexer marks receipt as invalid_for_discovery
receipt remains visible but not score-bearing
```

## Suggested Foundry Structure

```txt
contracts/
  DeezerbotResolver.sol
  TrackRegistry.sol
  DiscoveryPool.sol
  MockRoyaltySplitter.sol

test/
  DeezerbotGoldGate.t.sol

script/
  RegisterProofOfFanSchema.s.sol
  DeployDeezerbotResolver.s.sol
```

## Test Names

```txt
testTenUniqueNoncesPass()
testDuplicateNonceRejects()
testInvalidActionTypeRejects()
testZeroAddressFanRejects()
testMilestoneReleaseOnce()
testTimestampDriftMarkedInvalidByIndexer()
```

## Deployment Record

Fill only after human-signed execution:

```txt
base_chain_id=8453
schema_uid=
schema_registration_tx=
resolver_address=
resolver_deploy_tx=
track_registry_address=
discovery_pool_address=
split_factory_address=
first_test_attestation_uid=
first_test_attestation_tx=
```

## Verdict

```txt
GOLD=false until all required values above are filled and test results are attached.
```

Receipts over streams. Fans over farms. Artists over extraction.
