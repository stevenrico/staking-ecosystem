// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

/**
 * @dev A library for managing access lists used in {AccessCheckout}.
 *
 * `AccessList.tickets` manages a BitMap, a uint256 to bool mapping in a compact and efficient way, providing the keys are sequential.
 *
 * Using OpenZeppelin's implementation of {BitMaps} and inspired by Uniswap's
 * https://github.com/Uniswap/merkle-distributor/blob/master/contracts/MerkleDistributor.sol[merkle-distributor].
 *
 * Include with `using AccessLists for AccessLists.AccessList`.
 */
library AccessLists {
    struct AccessListConfig {
        uint256 maxSupply;
        uint256 price;
    }

    struct AccessList {
        uint256 maxSupply;
        uint256 price;
        mapping(uint256 => uint256) tickets;
    }

    /**
     * @dev Error thrown when the incorrect amount is sent to the contract.
     */
    error IncorrectAmount();

    /**
     * @dev Error thrown when the ticket is not valid or has already been claimed.
     */
    error InvalidTicket();

    /**
     * @dev Sets the access list's max supply.
     *
     * @param list              The access list.
     * @param maxSupply         The max supply, for the access list.
     */
    function setMaxSupply(AccessList storage list, uint256 maxSupply) internal {
        list.maxSupply = maxSupply;
    }

    /**
     * @dev Sets the access list's mint price.
     *
     * @param list              The access list.
     * @param price             The price of the mint, for the access list.
     */
    function setPrice(AccessList storage list, uint256 price) internal {
        list.price = price;
    }

    /**
     * @dev Sets tickets (bits) from 0 to max supply.
     *
     * @param list              The access list.
     */
    function setTickets(AccessList storage list) internal {
        for (uint256 i = 0; i < list.maxSupply; i++) {
            setTicket(list, i);
        }
    }

    /**
     * @dev Verify the purchase amount for a mint for the access list, from memory.
     *
     * Reverts if purchase amount does not equal price.
     *
     * @param list              The access list.
     * @param amount            The purchase amount.
     */
    function verifyPurchaseAmount(AccessList storage list, uint256 amount) internal view {
        if (amount != list.price) revert IncorrectAmount();
    }

    /**
     * @dev Validates the ticket (bit) by `ticketId` (index).
     *
     * Reverts if ticket is not valid.
     *
     * @param list              The access list.
     * @param ticketId          The ticket id to get the value from.
     */
    function validateTicketById(AccessList storage list, uint256 ticketId) internal view {
        if (!getTicket(list, ticketId)) revert InvalidTicket();
    }

    /**
     * @dev Returns whether the ticket (bit) at `index` is set.
     *
     * @param list              The access list.
     * @param index             The index to get the value from.
     *
     * @return value            The boolean value set at the index.
     */
    function getTicket(AccessList storage list, uint256 index) internal view returns (bool) {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        return list.tickets[bucket] & mask != 0;
    }

    /**
     * @dev Sets the ticket (bit) at `index` to the boolean `value`.
     *
     * @param list              The access list.
     * @param index             The index to get the value from.
     * @param value             The boolean value to set at the index.
     */
    function setTicketTo(AccessList storage list, uint256 index, bool value) internal {
        if (value) {
            setTicket(list, index);
        } else {
            unsetTicket(list, index);
        }
    }

    /**
     * @dev Sets the ticket (bit) at `index`.
     *
     * @param list              The access list.
     * @param index             The index to set the value at.
     */
    function setTicket(AccessList storage list, uint256 index) internal {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        list.tickets[bucket] |= mask;
    }

    /**
     * @dev Unsets the ticket (bit) at `index`.
     *
     * @param list              The access list.
     * @param index             The index to unset the value at.
     */
    function unsetTicket(AccessList storage list, uint256 index) internal {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        list.tickets[bucket] &= ~mask;
    }
}
