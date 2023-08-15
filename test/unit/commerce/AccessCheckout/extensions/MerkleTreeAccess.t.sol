// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import { Test } from "@forge-std/Test.sol";
import { AccessCheckoutMerkleTree } from "contracts/commerce/AccessCheckout/extensions/AccessCheckoutMerkleTree.sol";

import { AccessLists } from "contracts/commerce/structs/AccessLists.sol";
import { Products } from "contracts/commerce/structs/Products.sol";

import { Strings } from "@openzeppelin/utils/Strings.sol";

contract AccessCheckoutMerkleTreeUnit is Test {
    using Strings for uint256;
    using Strings for address;

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

        _minters = _generateUsers(ACCESS_MAX_SUPPLY, "MINTER");

        bytes32 root = _getMerkleTreeRoot();

        _checkout = new AccessCheckoutMerkleTree(product_, config_, root);
    }

    function _generateUsers(uint256 numOfUsers, string memory group) private returns (address[] memory) {
        address[] memory users = new address[](numOfUsers);

        uint256 startIndex = 1000;

        for (uint256 i = 0; i < numOfUsers; i++) {
            uint256 privateKey = startIndex + i;

            address user = vm.addr(privateKey);
            vm.label(user, string.concat("[", group, " | ", privateKey.toString(), "]"));
            vm.deal(user, 1 ether);

            users[i] = user;
        }

        return users;
    }

    function _getMerkleTreeRoot() private returns (bytes32) {
        string memory merkleTree =
            vm.readFile("./test/unit/commerce/utils/MerkleTree/outputs/AccessCheckoutMerkleTree.json");

        return vm.parseJsonBytes32(merkleTree, "$.root");
    }

    function _getProof(uint256 ticketId) private returns (bytes32[] memory) {
        string memory merkleTree =
            vm.readFile("./test/unit/commerce/utils/MerkleTree/outputs/AccessCheckoutMerkleTree.json");

        string memory key = string.concat("$.proofs.", ticketId.toString());

        return vm.parseJsonBytes32Array(merkleTree, key);
    }

    function test_ItVerifiesProof() external {
        address minter = _minters[0];
        uint256 ticketId = 0;
        bytes32[] memory proof = _getProof(ticketId);

        bool success = true;

        vm.prank(minter);
        _checkout.accessMint{ value: ACCESS_MINT_PRICE }(proof, ticketId);

        assertTrue(success);
    }

    function test_ItRevertsWhenProofVerificationFails() external {
        address minter = _minters[0];
        uint256 ticketId = 0;
        bytes32[] memory invalidProof = _getProof(1);

        vm.expectRevert(ProofVerificationFailure.selector);
        vm.prank(minter);
        _checkout.accessMint{ value: ACCESS_MINT_PRICE }(invalidProof, ticketId);
    }
}
