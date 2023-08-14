// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import { Products } from "contracts/commerce/structs/Products.sol";

contract Checkout {
    using Products for Products.Product;

    Products.Product internal _product;

    constructor(Products.Product memory product_) {
        _product = product_;
    }

    /**
     * @dev Get the product.
     *
     * @return product          The product.
     */
    function product() external view returns (Products.Product memory) {
        return _product;
    }

    /**
     * @dev Get the product's total supply.
     *
     * @return totalSupply      The total supply.
     */
    function totalSupply() external view returns (uint256) {
        return _product.totalSupply();
    }

    /**
     * @dev Checks if it's possible to mint a product and runs {_handleMint}.
     */
    function mint() external payable {
        Products.Product memory product_ = _product;

        product_.verifyPurchaseAmount(msg.value);

        _product.increment();

        _handleMint(msg.sender, product_.nextId());
    }

    /**
     * @dev Hook that is called at the end of {mint}.
     *
     * Override this function in the child contract that inherits {Checkout}.
     *
     * For ERC721 tokens, use {ERC721-_safeMint}.
     */
    function _handleMint(address recipient, uint256 id) internal virtual { }
}
