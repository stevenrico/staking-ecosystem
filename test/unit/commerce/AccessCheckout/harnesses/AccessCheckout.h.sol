// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import { AccessCheckout } from "contracts/commerce/AccessCheckout/AccessCheckout.sol";
import { AccessLists } from "contracts/commerce/structs/AccessLists.sol";
import { Products } from "contracts/commerce/structs/Products.sol";

contract AccessCheckoutHarness is AccessCheckout {
    using AccessLists for AccessLists.AccessList;

    struct HandleMintData {
        address recipient;
        uint256 id;
    }

    HandleMintData public handleMintData;

    constructor(Products.Product memory product_, AccessLists.AccessListConfig memory config_)
        AccessCheckout(product_, config_)
    { }

    function setAccessList(AccessLists.AccessListConfig memory config_) external {
        _setAccessList(config_);
    }

    function accessMint(uint256 purchaseAmount, uint256 ticketId) external {
        _accessMint(purchaseAmount, ticketId);
    }

    function getTicket(uint256 ticketId) external view returns (bool) {
        return _accessList.getTicket(ticketId);
    }

    function _handleMint(address recipient, uint256 id) internal override {
        handleMintData = HandleMintData(recipient, id);
    }
}
