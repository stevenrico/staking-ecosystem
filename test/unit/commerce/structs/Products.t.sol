// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import { Test } from "@forge-std/Test.sol";
import { Products } from "contracts/commerce/structs/Products.sol";

contract ProductsUnit is Test {
    using Products for Products.Product;

    Products.Product private _product;

    error IncorrectAmount();
    error MaxSupplyReached();

    function setUp() external {
        _product = Products.Product({ maxSupply: 10, price: 0.1 ether, currentSupply: 0 });
    }

    function test_MaxSupply() external {
        assertEq(_product.maxSupply, 10);
    }

    function test_Price() external {
        assertEq(_product.price, 0.1 ether);
    }

    function test_CurrentSupply() external {
        assertEq(_product.currentSupply, 0);
    }

    function test_TotalSupply() external {
        assertEq(_product.totalSupply(), 0);
    }

    function test_WhenInMemory_ItVerifiesPurchaseAmount() external {
        bool success = true;

        Products.Product memory product = _product;

        product.verifyPurchaseAmount(0.1 ether);

        assertTrue(success);
    }

    function test_WhenInMemory_ItRevertsWhenPurchaseAmountIsIncorrect() external {
        Products.Product memory product = _product;

        vm.expectRevert(IncorrectAmount.selector);
        product.verifyPurchaseAmount(0.05 ether);
    }

    function test_WhenInMemory_NextId() external {
        Products.Product memory product = _product;

        assertEq(product.nextId(), 1);
    }

    function test_ItSetsMaxSupply() external {
        _product.setMaxSupply(20);

        assertEq(_product.maxSupply, 20);
    }

    function test_ItSetsPrice() external {
        _product.setPrice(0.2 ether);

        assertEq(_product.price, 0.2 ether);
    }

    function test_OnIncrement_ItIncrementsByOne() external {
        _product.increment();

        assertEq(_product.currentSupply, 1);
    }

    function test_OnIncrement_ItRevertsWhenMaxSupplyIsReached() external {
        for (uint256 i = 0; i < 10; i++) {
            _product.increment();
        }

        vm.expectRevert(MaxSupplyReached.selector);
        _product.increment();
    }

    function test_OnIncrementBy_ItIncrementsByAGivenAmount() external {
        _product.incrementBy(5);

        assertEq(_product.currentSupply, 5);
    }

    function test_OnIcrementBy_ItRevertsWhenMaxSupplyIsReached() external {
        _product.incrementBy(10);

        vm.expectRevert(MaxSupplyReached.selector);
        _product.incrementBy(5);
    }

    function test_OnDecrement_ItDecrementsByOne() external {
        _product.currentSupply = 5;
        _product.decrement();

        assertEq(_product.currentSupply, 4);
    }

    function test_OnDecrement_ItUnderflows() external {
        _product.decrement();

        assertTrue(_product.currentSupply > 0);
    }

    function test_OnDecrementBy_ItDecrementsByAGivenAmount() external {
        _product.currentSupply = 5;
        _product.decrementBy(5);

        assertEq(_product.currentSupply, 0);
    }

    function test_OnDecrementBy_ItUnderflows() external {
        uint256 amount = 5;

        _product.decrementBy(amount);

        assertTrue(_product.currentSupply > amount);
    }
}
