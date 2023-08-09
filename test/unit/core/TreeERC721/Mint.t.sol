// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import { Test } from "@forge-std/Test.sol";
import { TreeERC721 } from "contracts/core/TreeERC721.sol";

import { ERC721ReceiverMock } from "@openzeppelin/mocks/token/ERC721ReceiverMock.sol";
import { MockContract } from "tests/mocks/MockContract.sol";

contract MintUnit is Test {
    TreeERC721 private _tree;

    uint256 public constant MAX_SUPPLY = 2000;
    uint256 public constant MINT_PRICE = 0.3 ether;

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    error IncorrectAmount();
    error MaxSupplyReached(address sender);

    address private _minter;

    address private _contractWithReceiver;
    address private _contractWithoutReceiver;

    function setUp() external {
        _tree = new TreeERC721();

        _minter = vm.addr(1000);
        vm.label(_minter, "[MINTER | EOA]");
        vm.deal(_minter, 1000 ether);

        _contractWithReceiver = _generateContractWithReceiver();
        _contractWithoutReceiver = _generateContractWithoutReceiver();
    }

    function _generateContractWithReceiver() private returns (address) {
        bytes4 retval = ERC721ReceiverMock.onERC721Received.selector;
        ERC721ReceiverMock.Error errorType = ERC721ReceiverMock.Error.None;

        ERC721ReceiverMock mockContract = new ERC721ReceiverMock(retval, errorType);

        address contractAddr = address(mockContract);

        vm.label(contractAddr, "[MINTER | CONTRACT WITH RECEIVER]");
        vm.deal(contractAddr, 10 ether);

        return contractAddr;
    }

    function _generateContractWithoutReceiver() private returns (address) {
        MockContract mockContract = new MockContract();

        address contractAddr = address(mockContract);

        vm.label(contractAddr, "[MINTER | CONTRACT WITHOUT RECEIVER]");
        vm.deal(contractAddr, 10 ether);

        return contractAddr;
    }

    function test_OnFirstMint_ItStartsWithAnIdOfOne() external {
        vm.prank(_minter);
        _tree.mint{ value: MINT_PRICE }();

        assertEq(_tree.ownerOf(1), _minter);
    }

    function test_OnSecondMint_ItIncrementsByOne() external {
        vm.startPrank(_minter);

        _tree.mint{ value: MINT_PRICE }();
        _tree.mint{ value: MINT_PRICE }();

        vm.stopPrank();

        assertEq(_tree.ownerOf(2), _minter);
    }

    function test_ItRevertsWhenMaxSupplyIsReached() external {
        vm.startPrank(_minter);

        for (uint256 i = 0; i < MAX_SUPPLY; i++) {
            _tree.mint{ value: MINT_PRICE }();
        }

        vm.expectRevert(abi.encodeWithSelector(MaxSupplyReached.selector, _minter));
        _tree.mint{ value: MINT_PRICE }();

        vm.stopPrank();
    }

    function test_WhenCallerIsEOA_ItTransfersToken() external {
        _itTransfersToken(_minter);
    }

    function test_WhenCallerIsEOA_ItEmitsTransferEvent() external {
        _itEmitsTransferEvent(_minter);
    }

    function test_WhenCallerIsEOA_ItReceivesPayment() external {
        _itReceivesPayment(_minter);
    }

    function test_WhenCallerIsEOA_ItUpdatesTotalSupply() external {
        _itUpdatesTotalSupply(_minter);
    }

    function test_WhenCallerIsEOA_ItRevertsWhenIncorrectAmountSent() external {
        _itRevertsWhenIncorrectAmountSent(_minter, 0.1 ether);
    }

    function test_WhenCallerIsAContract_WithERC721Receiver_ItTransfersToken() external {
        _itTransfersToken(_contractWithReceiver);
    }

    function test_WhenCallerIsAContract_WithERC721Receiver_ItEmitsTransferEvent() external {
        _itEmitsTransferEvent(_contractWithReceiver);
    }

    function test_WhenCallerIsAContract_WithERC721Receiver_ItReceivesPayment() external {
        _itReceivesPayment(_contractWithReceiver);
    }

    function test_WhenCallerIsAContract_WithERC721Receiver_ItUpdatesTotalSupply() external {
        _itUpdatesTotalSupply(_contractWithReceiver);
    }

    function test_WhenCallerIsAContract_WithERC721Receiver_ItRevertsWhenIncorrectAmountSent() external {
        _itRevertsWhenIncorrectAmountSent(_contractWithReceiver, 0.1 ether);
    }

    function test_WhenCallerIsAContract_WithoutERC721Receiver_ItReverts() external {
        vm.expectRevert("ERC721: transfer to non ERC721Receiver implementer");
        vm.prank(_contractWithoutReceiver);
        _tree.mint{ value: MINT_PRICE }();
    }

    function _itTransfersToken(address account) private {
        vm.prank(account);
        _tree.mint{ value: MINT_PRICE }();

        assertEq(_tree.balanceOf(account), 1);
    }

    function _itEmitsTransferEvent(address account) private {
        vm.expectEmit(true, true, true, false, address(_tree));
        emit Transfer(address(0), account, 1);

        vm.prank(account);
        _tree.mint{ value: MINT_PRICE }();
    }

    function _itReceivesPayment(address account) private {
        vm.prank(account);
        _tree.mint{ value: MINT_PRICE }();

        assertEq(address(_tree).balance, MINT_PRICE);
    }

    function _itUpdatesTotalSupply(address account) private {
        vm.prank(account);
        _tree.mint{ value: MINT_PRICE }();

        assertEq(_tree.totalSupply(), 1);
    }

    function _itRevertsWhenIncorrectAmountSent(address account, uint256 amount) private {
        vm.expectRevert(IncorrectAmount.selector);
        vm.prank(account);
        _tree.mint{ value: amount }();
    }
}
