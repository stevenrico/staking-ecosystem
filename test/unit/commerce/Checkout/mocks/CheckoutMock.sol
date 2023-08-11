// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import { Checkout } from "contracts/commerce/Checkout/Checkout.sol";

import { Products } from "contracts/commerce/structs/Products.sol";

contract CheckoutMock is Checkout {
    struct HandleMintData {
        address recipient;
        uint256 id;
    }

    HandleMintData public handleMintData;

    constructor(Products.Product memory product_) Checkout(product_) { }

    function _handleMint(address recipient, uint256 id) internal override {
        handleMintData = HandleMintData(recipient, id);
    }
}
