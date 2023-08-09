// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import { ERC721 } from "@openzeppelin/token/ERC721/ERC721.sol";

import { Ownable2Step } from "@openzeppelin/access/Ownable2Step.sol";

contract TreeERC721 is ERC721, Ownable2Step {
    uint256 public constant MAX_SUPPLY = 2000;
    uint256 public constant MINT_PRICE = 0.3 ether;

    uint256 private _tokenIndex;

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
     * @dev Error thrown when the incorrect amount is sent to the contract.
     */
    error IncorrectAmount();

    /**
     * @dev Error thrown when the max supply has been reached.
     *
     * @param sender            The address of `msg.sender`.
     */
    error MaxSupplyReached(address sender);

    /**
     * @dev Sets the {ERC721-name} and {ERC721-symbol}.
     */
    constructor() ERC721("Tree NFT", "TREE") { }

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
     * @dev Get the total supply.
     *
     * @return totalSupply      The total supply.
     */
    function totalSupply() public view returns (uint256) {
        return _tokenIndex;
    }

    /**
     * @dev Private function to get the next token's id.
     *
     * @return tokenId          The next token's id.
     */
    function _nextTokenId() private view returns (uint256) {
        unchecked {
            return _tokenIndex + 1;
        }
    }

    /**
     * @dev Mints a token and transfers it to `msg.sender`.
     *
     * When `msg.sender` is a contract, {ERC721-_safeMint} checks if the contract
     * is an {IERC721Receiver} capable of receving ERC721 tokens.
     *
     * Emits a {IERC721-Transfer} event.
     */
    function mint() external payable {
        if (msg.value != MINT_PRICE) revert IncorrectAmount();

        uint256 tokenId = _nextTokenId();

        if (tokenId > MAX_SUPPLY) revert MaxSupplyReached(msg.sender);

        unchecked {
            _tokenIndex += 1;
        }

        _safeMint(msg.sender, tokenId);
    }
}
