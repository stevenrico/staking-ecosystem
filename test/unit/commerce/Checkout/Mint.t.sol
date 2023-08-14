// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

// solhint-disable-next-line no-unused-import
import { Test, stdStorage, StdStorage } from "@forge-std/Test.sol";
import { Checkout } from "contracts/commerce/Checkout/Checkout.sol";

import { Products } from "contracts/commerce/structs/Products.sol";
import { CheckoutHarness } from "tests/unit/commerce/Checkout/harnesses/Checkout.h.sol";

contract MintUnit is Test {
    using stdStorage for StdStorage;

    Checkout private _checkout;
    CheckoutHarness private _checkoutHarness;

    uint256 public constant MAX_SUPPLY = 10;
    uint256 public constant MINT_PRICE = 0.1 ether;

    error IncorrectAmount();
    error MaxSupplyReached();

    address private _minter;

    function setUp() external {
        Products.Product memory product =
            Products.Product({ maxSupply: MAX_SUPPLY, price: MINT_PRICE, currentSupply: 0 });

        _checkout = new Checkout(product);
        _checkoutHarness = new CheckoutHarness(product);

        _minter = vm.addr(1000);
        vm.label(_minter, "[MINTER | 1000]");
        vm.deal(_minter, 10 ether);
    }

    function test_ItUpdatesProductCurrentSupply() external {
        vm.prank(_minter);
        _checkout.mint{ value: MINT_PRICE }();

        assertEq(_checkout.totalSupply(), 1);
    }

    function test_ItCallsHandleMint() external {
        vm.prank(_minter);
        _checkoutHarness.mint{ value: MINT_PRICE }();

        (address recipient, uint256 id) = _checkoutHarness.handleMintData();

        assertEq(recipient, _minter);
        assertEq(id, 1);
    }

    function test_ItRevertsWhenPurchaseAmountIsIncorrect() external {
        vm.expectRevert(IncorrectAmount.selector);
        vm.prank(_minter);
        _checkout.mint{ value: 0.05 ether }();
    }

    function test_ItRevertsWhenMaxSupplyIsReached() external {
        stdstore.target(address(_checkout)).sig("product()").depth(2).checked_write(10);

        vm.expectRevert(MaxSupplyReached.selector);
        vm.prank(_minter);
        _checkout.mint{ value: MINT_PRICE }();
    }
}
