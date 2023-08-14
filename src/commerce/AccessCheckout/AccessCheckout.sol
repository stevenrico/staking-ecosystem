// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import { Checkout } from "contracts/commerce/Checkout/Checkout.sol";
import { AccessLists } from "contracts/commerce/structs/AccessLists.sol";
import { Products } from "contracts/commerce/structs/Products.sol";

contract AccessCheckout is Checkout {
    using AccessLists for AccessLists.AccessList;
    using Products for Products.Product;

    AccessLists.AccessList internal _accessList;

    constructor(Products.Product memory product_, AccessLists.AccessListConfig memory config_) Checkout(product_) {
        _setAccessList(config_);
    }

    /**
     * @dev Sets access list, with an {AccessLists.AccessListConfig}.
     *
     * Sets the tickets BitMap to track claimed tickets.
     *
     * @param config_           An {AccessLists.AccessListConfig}.
     */
    function _setAccessList(AccessLists.AccessListConfig memory config_) internal virtual {
        _accessList.setMaxSupply(config_.maxSupply);
        _accessList.setPrice(config_.price);
        _accessList.setTickets();
    }

    /**
     * @dev Gets access list, returns an {AccessLists.AccessListConfig}.
     *
     * Does not return the tickets BitMap to track claimed tickets.
     *
     * @return config_          An {AccessLists.AccessListConfig}.
     */
    function accessList() external view returns (AccessLists.AccessListConfig memory) {
        return AccessLists.AccessListConfig(_accessList.maxSupply, _accessList.price);
    }

    /**
     * @dev Checks if it's possible to mint a product via the access list, updates the `product`,
     * and runs {_handleMint}.
     *
     * @param purchaseAmount    The purchase amount sent for the mint, usually `msg.value`.
     * @param ticketId          The ticket's id for the aceess list.
     */
    function _accessMint(uint256 purchaseAmount, uint256 ticketId) internal {
        Products.Product memory product_ = _product;

        _accessList.verifyPurchaseAmount(purchaseAmount);
        _accessList.validateTicketById(ticketId);
        _accessList.unsetTicket(ticketId);

        _product.increment();

        _handleMint(msg.sender, product_.nextId());
    }
}
