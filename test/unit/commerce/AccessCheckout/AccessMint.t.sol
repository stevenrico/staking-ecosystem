// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import { Test } from "@forge-std/Test.sol";
import { AccessCheckoutHarness } from "tests/unit/commerce/AccessCheckout/harnesses/AccessCheckout.h.sol";

import { AccessLists } from "contracts/commerce/structs/AccessLists.sol";
import { Products } from "contracts/commerce/structs/Products.sol";

contract AccessMintUnit is Test {
    AccessCheckoutHarness private _checkoutHarness;

    uint256 public constant MAX_SUPPLY = 10;
    uint256 public constant MINT_PRICE = 0.1 ether;

    uint256 public constant ACCESS_MAX_SUPPLY = 5;
    uint256 public constant ACCESS_MINT_PRICE = 0.05 ether;

    error IncorrectAmount();
    error InvalidTicket();

    address private _minter;

    function setUp() external {
        Products.Product memory product_ =
            Products.Product({ maxSupply: MAX_SUPPLY, price: MINT_PRICE, currentSupply: 0 });

        AccessLists.AccessListConfig memory config_ =
            AccessLists.AccessListConfig({ maxSupply: ACCESS_MAX_SUPPLY, price: ACCESS_MINT_PRICE });

        _checkoutHarness = new AccessCheckoutHarness(product_, config_);

        _minter = vm.addr(1000);
        vm.label(_minter, "[MINTER | 1000]");
        vm.deal(_minter, 10 ether);
    }

    function test_ItUnsetsTheTicket() external {
        uint256 ticketId = 0;

        vm.prank(_minter);
        _checkoutHarness.accessMint(ACCESS_MINT_PRICE, ticketId);

        assertFalse(_checkoutHarness.getTicket(ticketId));
    }

    function test_ItUpdatesProductCurrentSupply() external {
        uint256 ticketId = 0;

        vm.prank(_minter);
        _checkoutHarness.accessMint(ACCESS_MINT_PRICE, ticketId);

        assertEq(_checkoutHarness.totalSupply(), 1);
    }

    function test_ItCallsHandleMint() external {
        uint256 ticketId = 0;

        vm.prank(_minter);
        _checkoutHarness.accessMint(ACCESS_MINT_PRICE, ticketId);

        (address recipient, uint256 id) = _checkoutHarness.handleMintData();

        assertEq(recipient, _minter);
        assertEq(id, 1);
    }

    function test_ItRevertsWhenPurchaseAmountIsIncorrect() external {
        uint256 purchaseAmount = 0.01 ether;
        uint256 ticketId = 0;

        vm.expectRevert(IncorrectAmount.selector);
        vm.prank(_minter);
        _checkoutHarness.accessMint(purchaseAmount, ticketId);
    }

    function test_ItRevertsWhenTicketIsInvalid() external {
        uint256 ticketId = 10;

        vm.expectRevert(InvalidTicket.selector);
        vm.prank(_minter);
        _checkoutHarness.accessMint(ACCESS_MINT_PRICE, ticketId);
    }
}
