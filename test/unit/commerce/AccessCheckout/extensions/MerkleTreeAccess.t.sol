// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import { Test } from "@forge-std/Test.sol";
import { AccessCheckoutMerkleTree } from "contracts/commerce/AccessCheckout/extensions/AccessCheckoutMerkleTree.sol";

import { AccessLists } from "contracts/commerce/structs/AccessLists.sol";
import { Products } from "contracts/commerce/structs/Products.sol";

import { Users } from "tests/utils/Users.sol";
import { MerkleTree } from "tests/unit/commerce/utils/MerkleTree/MerkleTree.sol";

import { Strings } from "@openzeppelin/utils/Strings.sol";

contract AccessCheckoutMerkleTreeUnit is Test {
    using Strings for uint256;

    AccessCheckoutMerkleTree private _checkout;

    uint256 public constant MAX_SUPPLY = 10;
    uint256 public constant MINT_PRICE = 0.1 ether;

    uint256 public constant ACCESS_MAX_SUPPLY = 5;
    uint256 public constant ACCESS_MINT_PRICE = 0.05 ether;

    error ProofVerificationFailure();

    address[] private _minters;

    function setUp() external {
        Products.Product memory product_ =
            Products.Product({ maxSupply: MAX_SUPPLY, price: MINT_PRICE, currentSupply: 0 });

        AccessLists.AccessListConfig memory config_ =
            AccessLists.AccessListConfig({ maxSupply: ACCESS_MAX_SUPPLY, price: ACCESS_MINT_PRICE });

        _minters = Users.generateUsers(1000, ACCESS_MAX_SUPPLY, "MINTER", 1 ether);

        bytes32 root = MerkleTree.getMerkleTreeRoot("AccessCheckoutMerkleTree.json");

        _checkout = new AccessCheckoutMerkleTree(product_, config_, root);
    }

    function test_ItVerifiesProof() external {
        address minter = _minters[0];
        uint256 ticketId = 0;
        string memory key = string.concat("$.proofs.", ticketId.toString());
        bytes32[] memory proof = MerkleTree.getProof("AccessCheckoutMerkleTree.json", key);

        bool success = true;

        vm.prank(minter);
        _checkout.accessMint{ value: ACCESS_MINT_PRICE }(proof, ticketId);

        assertTrue(success);
    }

    function test_ItRevertsWhenProofVerificationFails() external {
        address minter = _minters[0];
        uint256 ticketId = 1;
        string memory key = string.concat("$.proofs.", ticketId.toString());
        bytes32[] memory invalidProof = MerkleTree.getProof("AccessCheckoutMerkleTree.json", key);

        vm.expectRevert(ProofVerificationFailure.selector);
        vm.prank(minter);
        _checkout.accessMint{ value: ACCESS_MINT_PRICE }(invalidProof, ticketId);
    }
}
