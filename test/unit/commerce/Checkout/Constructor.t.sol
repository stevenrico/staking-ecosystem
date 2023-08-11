// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import { Test } from "@forge-std/Test.sol";
import { Checkout } from "contracts/commerce/Checkout/Checkout.sol";

import { Products } from "contracts/commerce/structs/Products.sol";

contract ConstructorUnit is Test {
    Checkout private _checkout;

    uint256 public constant MAX_SUPPLY = 10;
    uint256 public constant MINT_PRICE = 0.1 ether;

    function setUp() external {
        Products.Product memory product =
            Products.Product({ maxSupply: MAX_SUPPLY, price: MINT_PRICE, currentSupply: 0 });

        _checkout = new Checkout(product);
    }

    function test_ItSetsProduct() external {
        Products.Product memory product = _checkout.product();

        assertEq(product.maxSupply, MAX_SUPPLY);
        assertEq(product.price, MINT_PRICE);
        assertEq(product.currentSupply, 0);
    }
}
