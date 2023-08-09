// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

contract Contract {
    address private _owner;

    constructor() {
        _owner = msg.sender;
    }
}
