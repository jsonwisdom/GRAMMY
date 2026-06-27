// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../contracts/DeezerbotResolver.sol";

contract DeployResolver is Script {
    bytes32 constant SCHEMA_UID = 0x83354b10d997dd0da566f9d9bcb770284c024058b898c4821f3eeb6441c92dad;
    bytes32 constant HERITAGE_ROOT = 0xa1c499256eb8350ecd3b894ba97724e70bb7d7da32843c0f5eed5082f8319c38;

    function run() external returns (DeezerbotResolver resolver) {
        vm.startBroadcast();
        resolver = new DeezerbotResolver(SCHEMA_UID, HERITAGE_ROOT);
        vm.stopBroadcast();
    }
}
