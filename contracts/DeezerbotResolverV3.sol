// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @notice Minimal EAS-compatible resolver adapter for Deezerbot ProofOfFan.
/// @dev Avoids external imports so the repo can compile in the current Cloud Shell.
///      EAS calls `attest(Attestation)` on the resolver during native attestation flow.
contract DeezerbotResolverV3 {
    struct Attestation {
        bytes32 uid;
        bytes32 schema;
        uint64 time;
        uint64 expirationTime;
        uint64 revocationTime;
        bytes32 refUID;
        address recipient;
        address attester;
        bool revocable;
        bytes data;
    }

    address public immutable eas;
    bytes32 public immutable heritageRoot;

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

    error OnlyEAS();
    error InvalidFan();
    error InvalidActionType();
    error FutureTimestamp();
    error InvalidHeritageRoot();
    error NonceUsed();

    constructor(address _eas, bytes32 _heritageRoot) {
        eas = _eas;
        heritageRoot = _heritageRoot;
    }

    function attest(Attestation calldata attestation) external payable returns (bool) {
        if (msg.sender != eas) revert OnlyEAS();

        (
            bytes32 trackId,
            address fan,
            uint8 actionType,
            uint256 timestamp,
            bytes32 nonce,
            bytes32 suppliedHeritageRoot
        ) = abi.decode(attestation.data, (bytes32, address, uint8, uint256, bytes32, bytes32));

        if (fan == address(0)) revert InvalidFan();
        if (actionType > 2) revert InvalidActionType();
        if (timestamp > block.timestamp) revert FutureTimestamp();
        if (suppliedHeritageRoot != heritageRoot) revert InvalidHeritageRoot();
        if (usedNonces[nonce]) revert NonceUsed();

        usedNonces[nonce] = true;
        uint256 weight = _weight(actionType);
        uint256 totalWeight = totalWeightByTrack[trackId] + weight;
        totalWeightByTrack[trackId] = totalWeight;

        emit ProofOfFanAccepted(trackId, fan, nonce, actionType, weight, totalWeight);
        return true;
    }

    function revoke(Attestation calldata) external payable returns (bool) {
        if (msg.sender != eas) revert OnlyEAS();
        return true;
    }

    function _weight(uint8 actionType) internal pure returns (uint256) {
        if (actionType == 0) return 1;
        if (actionType == 1) return 5;
        return 20;
    }
}
