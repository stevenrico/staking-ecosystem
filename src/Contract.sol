// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract Contract {
    address private _owner;

    constructor() {
        _owner = msg.sender;
    }
}
