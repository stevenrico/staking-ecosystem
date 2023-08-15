// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import { AccessCheckout } from "contracts/commerce/AccessCheckout/AccessCheckout.sol";
import { AccessLists } from "contracts/commerce/structs/AccessLists.sol";
import { Products } from "contracts/commerce/structs/Products.sol";

import { MerkleProof } from "@openzeppelin/utils/cryptography/MerkleProof.sol";

contract AccessCheckoutMerkleTree is AccessCheckout {
    /**
     * @dev Error thrown when the proof sent fails to verify.
     */
    error ProofVerificationFailure();

    bytes32 private _root;

    constructor(Products.Product memory product_, AccessLists.AccessListConfig memory accessListsConfig_, bytes32 root)
        AccessCheckout(product_, accessListsConfig_)
    {
        _root = root;
    }

    /**
     * @dev Sets the Merkle Tree `_root`.
     */
    function setMerkleTreeRoot(bytes32 root) external {
        _root = root;
    }

    /**
     * @dev Verifies a Merkle Tree `proof` and runs {AccessCheckout-_accessMint}.
     *
     * @param proof             The Merkle Tree proof.
     * @param ticketId          The ticket id for the access list.
     */
    function accessMint(bytes32[] calldata proof, uint256 ticketId) external payable {
        _verifyProof({ proof: proof, ticketId: ticketId, customer: msg.sender });

        _accessMint(msg.value, ticketId);
    }

    /**
     * @dev Verifies a Merkle Tree `proof` and `leaf`.
     *
     * Reverts if verification fails.
     *
     * @param proof             The Merkle Tree proof.
     * @param ticketId          The ticket id for the access list.
     * @param customer          The address of the customer, usually `msg.sender`.
     */
    function _verifyProof(bytes32[] calldata proof, uint256 ticketId, address customer) internal view {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(ticketId, customer))));

        bool success = MerkleProof.verify({ proof: proof, root: _root, leaf: leaf });

        if (!success) revert ProofVerificationFailure();
    }
}
