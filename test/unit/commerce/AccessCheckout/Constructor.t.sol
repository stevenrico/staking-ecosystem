// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import { Test } from "@forge-std/Test.sol";
import { AccessCheckout } from "contracts/commerce/AccessCheckout/AccessCheckout.sol";
import { AccessCheckoutHarness } from "tests/unit/commerce/AccessCheckout/harnesses/AccessCheckout.h.sol";

import { AccessLists } from "contracts/commerce/structs/AccessLists.sol";
import { Products } from "contracts/commerce/structs/Products.sol";

contract ConstructorUnit is Test {
    AccessCheckout private _checkout;
    AccessCheckoutHarness private _checkoutHarness;

    uint256 public constant MAX_SUPPLY = 10;
    uint256 public constant MINT_PRICE = 0.1 ether;

    uint256 public constant ACCESS_MAX_SUPPLY = 5;
    uint256 public constant ACCESS_MINT_PRICE = 0.05 ether;

    function setUp() external {
        Products.Product memory product_ =
            Products.Product({ maxSupply: MAX_SUPPLY, price: MINT_PRICE, currentSupply: 0 });

        AccessLists.AccessListConfig memory config_ =
            AccessLists.AccessListConfig({ maxSupply: ACCESS_MAX_SUPPLY, price: ACCESS_MINT_PRICE });

        _checkout = new AccessCheckout(product_, config_);
        _checkoutHarness = new AccessCheckoutHarness(product_, config_);
    }

    function test_ItSetsProduct() external {
        Products.Product memory product_ = _checkout.product();

        assertEq(product_.maxSupply, MAX_SUPPLY);
        assertEq(product_.price, MINT_PRICE);
        assertEq(product_.currentSupply, 0);
    }

    function test_ItSetsAccessList() external {
        AccessLists.AccessListConfig memory config_ = _checkoutHarness.accessList();

        bool isSet = false;

        for (uint256 i = 0; i < ACCESS_MAX_SUPPLY; i++) {
            isSet = _checkoutHarness.getTicket(i);
        }

        assertEq(config_.maxSupply, ACCESS_MAX_SUPPLY);
        assertEq(config_.price, ACCESS_MINT_PRICE);
        assertTrue(isSet);
    }
}
