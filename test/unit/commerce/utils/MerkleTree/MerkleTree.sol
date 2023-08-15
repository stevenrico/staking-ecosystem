// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import { Vm } from "@forge-std/Vm.sol";

import { Strings } from "@openzeppelin/utils/Strings.sol";

library MerkleTree {
    using Strings for uint256;

    /* solhint-disable */
    address internal constant VM_ADDRESS = address(uint160(uint256(keccak256("hevm cheat code"))));

    Vm internal constant vm = Vm(VM_ADDRESS);
    /* solhint-enable */

    function getMerkleTreeRoot(string memory filename) internal returns (bytes32) {
        string memory path = string.concat("./test/unit/commerce/utils/MerkleTree/outputs/", filename);

        string memory merkleTree = vm.readFile(path);

        return vm.parseJsonBytes32(merkleTree, "$.root");
    }

    function getProof(string memory filename, string memory key) internal returns (bytes32[] memory) {
        string memory path = string.concat("./test/unit/commerce/utils/MerkleTree/outputs/", filename);

        string memory merkleTree = vm.readFile(path);

        return vm.parseJsonBytes32Array(merkleTree, key);
    }
}
