// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

/**
 * @dev A library for managing products used in {Checkout}.
 *
 * Include with `using Products for Products.Product`.
 */
library Products {
    struct Product {
        uint256 maxSupply;
        uint256 price;
        uint256 currentSupply;
    }

    /**
     * @dev Error thrown when the incorrect amount is sent to the contract.
     */
    error IncorrectAmount();

    /**
     * @dev Error thrown when the max supply has been reached.
     */
    error MaxSupplyReached();

    /**
     * @dev Sets the product's max supply.
     *
     * @param product           The product.
     * @param maxSupply         The max supply of the product.
     */
    function setMaxSupply(Product storage product, uint256 maxSupply) internal {
        product.maxSupply = maxSupply;
    }

    /**
     * @dev Sets the product's price.
     *
     * @param product           The product.
     * @param price             The price of the product.
     */
    function setPrice(Product storage product, uint256 price) internal {
        product.price = price;
    }

    /**
     * @dev Get the product's total supply.
     *
     * @param product           The product.
     *
     * @return totalSupply      The total supply of the product.
     */
    function totalSupply(Product storage product) internal view returns (uint256) {
        return product.currentSupply;
    }

    /**
     * @dev Verify the purchase amount for a product, from memory.
     *
     * Reverts if purchase amount does not equal price.
     *
     * @param product           The product.
     * @param amount            The purchase amount.
     */
    function verifyPurchaseAmount(Product memory product, uint256 amount) internal pure {
        if (amount != product.price) revert IncorrectAmount();
    }

    /**
     * @dev Get the product's next id, from memory.
     *
     * @param product           The product.
     *
     * @return nextId           The id of the next product.
     */
    function nextId(Product memory product) internal pure returns (uint256) {
        unchecked {
            return product.currentSupply + 1;
        }
    }

    /**
     * @dev Increment the product's supply by 1.
     *
     * Reverts if max supply reached.
     *
     * @param product           The product.
     */
    function increment(Product storage product) internal {
        Product memory product_ = product;

        if (nextId(product_) > product_.maxSupply) revert MaxSupplyReached();

        unchecked {
            product.currentSupply += 1;
        }
    }

    /**
     * @dev Increment the product's supply by an amount.
     *
     * Reverts if max supply reached.
     *
     * @param product           The product.
     * @param amount            The amount to increment by.
     */
    function incrementBy(Product storage product, uint256 amount) internal {
        Product memory product_ = product;

        if ((product_.currentSupply + amount) > product_.maxSupply) revert MaxSupplyReached();

        unchecked {
            product.currentSupply += amount;
        }
    }

    /**
     * @dev Decrement the product's supply by 1.
     *
     * [WARNING]
     * ====
     * Does not check for underflow, for gas savings.
     *
     * If used with {ERC721-_burn} it is unlikely that `product.currentSupply` will
     * go below 0.
     *
     * If used with a custom implementation, use the below check before calling
     * this function:
     *
     * `require(product.currentSupply > 0, "Product: DECREMENT_UNDERFLOW");`
     * ====
     *
     * @param product           The product.
     */
    function decrement(Product storage product) internal {
        unchecked {
            product.currentSupply -= 1;
        }
    }

    /**
     * @dev Decrement the product's supply by an amount.
     *
     * [WARNING]
     * ====
     * Does not check for underflow, for gas savings.
     *
     * If used with {ERC721-_burn} it is unlikely that `product.currentSupply` will
     * go below 0.
     *
     * If used with a custom implementation, use the below check before calling
     * this function:
     *
     * `require((product.currentSupply + 1) - amount > 0, "Product: DECREMENT_UNDERFLOW");`
     * ====
     *
     * @param product           The product.
     * @param amount            The amount to decrement by.
     */
    function decrementBy(Product storage product, uint256 amount) internal {
        unchecked {
            product.currentSupply -= amount;
        }
    }
}
