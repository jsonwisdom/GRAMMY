// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract DeezerbotResolver {
    bytes32 public immutable schemaUid;
    bytes32 public immutable heritageRoot;
    address public immutable owner;

    mapping(bytes32 => bool) public usedNonces;
    mapping(bytes32 => uint256) public totalWeightByTrack;

    event ProofOfFanAccepted(
        bytes32 indexed trackId,
        address indexed fan,
        bytes32 indexed nonce,
        uint8 actionType,
        uint256 weight,
        uint256 totalWeight
    );

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
    ) external returns (uint256 totalWeight) {
        _validate(fan, actionType, timestamp, nonce, suppliedHeritageRoot);

        uint256 weight = _weight(actionType);
        usedNonces[nonce] = true;

        totalWeight = totalWeightByTrack[trackId] + weight;
        totalWeightByTrack[trackId] = totalWeight;

        emit ProofOfFanAccepted(trackId, fan, nonce, actionType, weight, totalWeight);
    }

    function _validate(
        address fan,
        uint8 actionType,
        uint256 timestamp,
        bytes32 nonce,
        bytes32 suppliedHeritageRoot
    ) internal view {
        if (fan == address(0)) revert InvalidFan();
        if (actionType > 2) revert InvalidActionType();
        if (timestamp > block.timestamp) revert FutureTimestamp();
        if (suppliedHeritageRoot != heritageRoot) revert InvalidHeritageRoot();
        if (usedNonces[nonce]) revert NonceUsed();
    }

    function _weight(uint8 actionType) internal pure returns (uint256) {
        if (actionType == 0) return 1;
        if (actionType == 1) return 5;
        return 20;
    }
}
