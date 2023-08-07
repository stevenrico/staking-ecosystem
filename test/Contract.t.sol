// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { Test } from "@forge-std/Test.sol";
import { Contract } from "contracts/Contract.sol";

contract ContractTest is Test {
    Contract private _contract;

    function setUp() external {
        _contract = new Contract();
    }
}
