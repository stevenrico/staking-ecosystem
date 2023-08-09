// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import { Test } from "@forge-std/Test.sol";
import { TreeERC721 } from "contracts/core/TreeERC721.sol";

contract WithdrawUnit is Test {
    TreeERC721 private _tree;

    error InsufficientBalance();

    address private _owner;
    address private _unauthorized;

    function setUp() external {
        _owner = vm.addr(1000);
        vm.label(_owner, "[OWNER | 1000]");
        vm.deal(_owner, 1 ether);

        vm.prank(_owner);
        _tree = new TreeERC721();

        _unauthorized = vm.addr(2000);
        vm.label(_unauthorized, "[UNAUTHORIZED | 2000]");
        vm.deal(_unauthorized, 1 ether);
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
