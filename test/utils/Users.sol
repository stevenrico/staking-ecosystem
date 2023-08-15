// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import { Vm } from "@forge-std/Vm.sol";

import { Strings } from "@openzeppelin/utils/Strings.sol";

library Users {
    using Strings for uint256;

    /* solhint-disable */
    address internal constant VM_ADDRESS = address(uint160(uint256(keccak256("hevm cheat code"))));

    Vm internal constant vm = Vm(VM_ADDRESS);
    /* solhint-enable */

    function generateUser(uint256 privateKey, string memory group, uint256 etherAmount) internal returns (address) {
        address user = vm.addr(privateKey);
        vm.label(user, string.concat("[", group, " | ", privateKey.toString(), "]"));
        vm.deal(user, etherAmount);

        return user;
    }

    function generateUsers(uint256 groupKey, uint256 numOfUsers, string memory group, uint256 etherAmount)
        internal
        returns (address[] memory)
    {
        address[] memory users = new address[](numOfUsers);

        for (uint256 i = 0; i < numOfUsers; i++) {
            uint256 privateKey = groupKey + i;

            address user = vm.addr(privateKey);
            vm.label(user, string.concat("[", group, " | ", privateKey.toString(), "]"));
            vm.deal(user, etherAmount);

            users[i] = user;
        }

        return users;
    }
}
