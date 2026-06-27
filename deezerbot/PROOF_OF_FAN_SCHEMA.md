# Deezerbot Proof-of-Fan Schema

## Production Schema String

Register this exact schema on Base EAS:

```solidity
ProofOfFan(bytes32 trackId,address fan,uint8 actionType,uint256 timestamp,bytes32 nonce)
```

## Field Rules

| Field | Type | Rule |
|---|---|---|
| `trackId` | `bytes32` | `keccak256(bytes(ipfsCid))` or canonical track metadata hash |
| `fan` | `address` | wallet performing the action |
| `actionType` | `uint8` | `0=listen`, `1=save/share`, `2=remix/tip` |
| `timestamp` | `uint256` | action timestamp; indexer rejects impossible drift |
| `nonce` | `bytes32` | unique per fan/action/track to prevent replay farming |

## Weight Table

```txt
0 listen     = 1
1 save/share = 5
2 remix/tip  = 20
```

## Registration Output

Fill after Base EAS registration:

```txt
schema_uid=
registration_tx=
resolver_address=
first_test_attestation_uid=
first_test_attestation_tx=
```

## Integrity Rule

No gold verdict until schema registration and at least one end-to-end test attestation verifies through the resolver/indexer path.

Receipts over streams. Fans over farms. Artists over extraction.
