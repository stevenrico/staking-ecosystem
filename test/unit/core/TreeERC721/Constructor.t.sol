// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import { Test } from "@forge-std/Test.sol";
import { TreeERC721 } from "contracts/core/TreeERC721.sol";

import { MerkleTree } from "tests/unit/commerce/utils/MerkleTree/MerkleTree.sol";

contract ConstructorUnit is Test {
    TreeERC721 private _tree;

    function setUp() external {
        bytes32 root = MerkleTree.getMerkleTreeRoot("AccessCheckoutMerkleTree.json");

        _tree = new TreeERC721(root);
    }

    function test_ItSetsName() external {
        assertEq(_tree.name(), "Tree NFT");
    }

    function test_ItSetsSymbol() external {
        assertEq(_tree.symbol(), "TREE");
    }
}
