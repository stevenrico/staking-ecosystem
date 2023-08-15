// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import { ERC721 } from "@openzeppelin/token/ERC721/ERC721.sol";

import { Ownable2Step } from "@openzeppelin/access/Ownable2Step.sol";

import { AccessCheckoutMerkleTree } from "contracts/commerce/AccessCheckout/extensions/AccessCheckoutMerkleTree.sol";
import { Products } from "contracts/commerce/structs/Products.sol";
import { AccessLists } from "contracts/commerce/structs/AccessLists.sol";

contract TreeERC721 is ERC721, AccessCheckoutMerkleTree, Ownable2Step {
    using Products for Products.Product;

    uint256 public constant MAX_SUPPLY = 2000;
    uint256 public constant MINT_PRICE = 0.3 ether;

    uint256 public constant ACCESS_MAX_SUPPLY = 400;
    uint256 public constant ACCESS_MINT_PRICE = 0.2 ether;

    /**
     * @dev Error thrown when the contract's balance is insufficent.
     */
    error InsufficientBalance();

    /**
     * @dev Error thrown when the transaction fails to send, the recipient may
     * have reverted.
     */
    error SendFailure();

    /**
     * @dev Setup {ERC721} and {Checkout}.
     *
     * - For {ERC721}, it sets the {ERC721-name} and {ERC721-symbol}.
     * - For {AccessCheckoutMerkleTree}, it sets the {Checkout-_product}, {AccessCheckout-_accesList}
     * and {AccessCheckoutMerkleTree-_root}.
     */
    constructor(bytes32 root)
        ERC721("Tree NFT", "TREE")
        AccessCheckoutMerkleTree(
            Products.Product({ maxSupply: MAX_SUPPLY, price: MINT_PRICE, currentSupply: 0 }),
            AccessLists.AccessListConfig({ maxSupply: ACCESS_MAX_SUPPLY, price: ACCESS_MINT_PRICE }),
            root
        )
    { }

    /**
     * @dev Withdraw accumulated balance from the contract.
     *
     * Restricts access to contract's owner, see {Ownable-onlyOwner}.
     */
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;

        if (balance == 0) revert InsufficientBalance();

        (bool success,) = msg.sender.call{ value: balance }("");

        if (!success) revert SendFailure();
    }

    /**
     * @dev Mints a token and transfers it to `msg.sender`.
     *
     * When `msg.sender` is a contract, {ERC721-_safeMint} checks if the contract
     * is an {IERC721Receiver} capable of receving ERC721 tokens.
     *
     * Emits a {IERC721-Transfer} event.
     */
    function _handleMint(address recipient, uint256 id) internal override {
        _safeMint(recipient, id);
    }
}
