// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import { Test } from "@forge-std/Test.sol";
import { TreeERC721 } from "contracts/core/TreeERC721.sol";

import { Users } from "tests/utils/Users.sol";
import { MerkleTree } from "tests/unit/commerce/utils/MerkleTree/MerkleTree.sol";

contract WithdrawUnit is Test {
    TreeERC721 private _tree;

    error InsufficientBalance();

    address private _owner;
    address private _unauthorized;

    function setUp() external {
        _owner = Users.generateUser(1000, "OWNER", 1 ether);

        bytes32 root = MerkleTree.getMerkleTreeRoot("AccessCheckoutMerkleTree.json");

        vm.prank(_owner);
        _tree = new TreeERC721(root);

        _unauthorized = Users.generateUser(2000, "UNAUTHORIZED", 1 ether);
    }

    function test_WhenCallerIsOwner_ItTransfersETH() external {
        uint256 currentBalanceOfOwner = _owner.balance;
        uint256 amount = 1 ether;

        vm.deal(address(_tree), amount);

        vm.prank(_owner);
        _tree.withdraw();

        assertEq(_owner.balance, currentBalanceOfOwner + amount);
    }

    function test_WhenCallerIsOwner_ItRevertsWhenBalanceIsZero() external {
        vm.expectRevert(InsufficientBalance.selector);
        vm.prank(_owner);
        _tree.withdraw();
    }

    function test_WhenCallerIsNotOwner_ItReverts() external {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(_unauthorized);
        _tree.withdraw();
    }
}
