// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @notice Deezerbot v0.1 nonce + heritage gate.
/// @dev This is a minimal routing gate for ProofOfFan payloads.
///      Important: an EAS schema can only enforce an onchain resolver if the resolver
///      address is attached when that schema is registered.
contract DeezerbotResolver {
    bytes32 public immutable schemaUid;
    bytes32 public immutable heritageRoot;
    address public immutable owner;

    mapping(bytes32 => bool) public usedNonces;
    mapping(bytes32 => uint256) public totalWeightByTrack;

    event ProofOfFanAccepted(
        bytes32 indexed trackId,
        address indexed fan,
        uint8 actionType,
        uint256 timestamp,
        bytes32 nonce,
        bytes32 heritageRoot,
        uint256 weight,
        uint256 totalWeight
    );

    error NotOwner();
    error InvalidFan();
    error InvalidActionType();
    error FutureTimestamp();
    error InvalidHeritageRoot();
    error NonceUsed();

    constructor(bytes32 _schemaUid, bytes32 _heritageRoot) {
        schemaUid = _schemaUid;
        heritageRoot = _heritageRoot;
        owner = msg.sender;
    }

    function submitProofOfFan(
        bytes32 trackId,
        address fan,
        uint8 actionType,
        uint256 timestamp,
        bytes32 nonce,
        bytes32 suppliedHeritageRoot
    ) external returns (uint256 weight) {
        if (fan == address(0)) revert InvalidFan();
        if (actionType > 2) revert InvalidActionType();
        if (timestamp > block.timestamp) revert FutureTimestamp();
        if (suppliedHeritageRoot != heritageRoot) revert InvalidHeritageRoot();
        if (usedNonces[nonce]) revert NonceUsed();

        usedNonces[nonce] = true;
        weight = _weight(actionType);
        totalWeightByTrack[trackId] += weight;

        emit ProofOfFanAccepted(
            trackId,
            fan,
            actionType,
            timestamp,
            nonce,
            suppliedHeritageRoot,
            weight,
            totalWeightByTrack[trackId]
        );
    }

    function _weight(uint8 actionType) internal pure returns (uint256) {
        if (actionType == 0) return 1;
        if (actionType == 1) return 5;
        return 20;
    }
}
