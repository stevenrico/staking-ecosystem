// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import { Test } from "@forge-std/Test.sol";
import { AccessLists } from "contracts/commerce/structs/AccessLists.sol";

contract AccessListUnit is Test {
    using AccessLists for AccessLists.AccessList;

    uint256 public constant ACCESS_MAX_SUPPLY = 10;
    uint256 public constant ACCESS_MINT_PRICE = 0.1 ether;

    AccessLists.AccessList private _accessList;

    error IncorrectAmount();
    error InvalidTicket();

    function setUp() external {
        AccessLists.AccessListConfig memory config_ =
            AccessLists.AccessListConfig({ maxSupply: ACCESS_MAX_SUPPLY, price: ACCESS_MINT_PRICE });

        _accessList.setMaxSupply(config_.maxSupply);
        _accessList.setPrice(config_.price);
        _accessList.setTickets();
    }

    function test_MaxSupply() external {
        assertEq(_accessList.maxSupply, ACCESS_MAX_SUPPLY);
    }

    function test_Price() external {
        assertEq(_accessList.price, ACCESS_MINT_PRICE);
    }

    function test_Tickets() external {
        bool isSet = false;

        for (uint256 i = 0; i < ACCESS_MAX_SUPPLY; i++) {
            isSet = _accessList.getTicket(i);
        }

        assertTrue(isSet);
    }

    function test_ItSetsMaxSupply() external {
        uint256 maxSupply = 20;

        _accessList.setMaxSupply(maxSupply);

        assertEq(_accessList.maxSupply, maxSupply);
    }

    function test_ItSetsPrice() external {
        uint256 price = 0.2 ether;

        _accessList.setPrice(price);

        assertEq(_accessList.price, price);
    }

    function test_WhenMaxSupplyIsSet_ItSetsTickets() external {
        uint256 maxSupply = 500;

        _accessList.setMaxSupply(maxSupply);
        _accessList.setTickets();

        bool isSet = false;

        for (uint256 i = 0; i < maxSupply; i++) {
            isSet = _accessList.getTicket(i);
        }

        assertTrue(isSet);
    }

    function test_ItVerifiesPurchaseAmount() external {
        bool success = true;

        _accessList.verifyPurchaseAmount(ACCESS_MINT_PRICE);

        assertTrue(success);
    }

    function test_ItRevertsWhenPurchaseAmountIsIncorrect() external {
        vm.expectRevert(IncorrectAmount.selector);
        _accessList.verifyPurchaseAmount(0.05 ether);
    }

    function test_ItValidatesTickets() external {
        uint256 ticketId = 0;

        bool success = true;

        _accessList.validateTicketById(ticketId);

        assertTrue(success);
    }

    function test_ItRevertsWhenTicketIsInvalid() external {
        vm.expectRevert(InvalidTicket.selector);
        _accessList.validateTicketById(10);
    }

    function test_OnGetTicket_WhenTicketIsValid_ItReturnsTrue() external {
        assertTrue(_accessList.getTicket(0));
    }

    function test_OnGetTicket_WhenTicketIsInvalid_ItReturnsFalse() external {
        assertFalse(_accessList.getTicket(10));
    }

    function test_OnSetTicketTo_WhenValueIsTrue_ItSetsTheTicket() external {
        uint256 ticketId = 10;

        _accessList.setTicketTo(ticketId, true);

        assertTrue(_accessList.getTicket(ticketId));
    }

    function test_OnSetTicketTo_WhenValueIsFalse_ItUnsetsTheTicket() external {
        uint256 ticketId = 0;

        _accessList.setTicketTo(ticketId, false);

        assertFalse(_accessList.getTicket(ticketId));
    }

    function test_OnSetTicket_ItSetsTheTicket() external {
        uint256 ticketId = 10;

        _accessList.setTicket(ticketId);

        assertTrue(_accessList.getTicket(ticketId));
    }

    function test_OnUnsetTicket_ItUnsetsTheTicket() external {
        uint256 ticketId = 0;

        _accessList.unsetTicket(ticketId);

        assertFalse(_accessList.getTicket(ticketId));
    }
}
