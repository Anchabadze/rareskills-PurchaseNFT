// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test} from "@forge-std/src/Test.sol";
import {console} from "@forge-std/src/console.sol";
import {PurchaseNFT} from "../src/PurchaseNFT.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("Mock Token", "MT") {
        _mint(msg.sender, 1_000_000 ether);
    }
}

contract TEST_PurchaseNFT is Test {
    PurchaseNFT public nft;
    MockERC20 public token;

    address owner = makeAddr("owner");
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2 ");

    function setUp() public {
        vm.startPrank(owner);
        token = new MockERC20();
        nft = new PurchaseNFT(address(token), 10 ether);
        token.transfer(user1, 1000 ether);
        token.transfer(user2, 1000 ether);
        vm.stopPrank();
    }

    function test_mintNFTfailedDueToInsufficientAllowance() public {
        vm.startPrank(user1);
        vm.expectRevert();
        nft.mint();
        vm.stopPrank();
    }

    function test_mintNFTSucceded() public {
        vm.startPrank(user1);
        token.approve(address(nft), 10 ether);
        nft.mint();
        vm.stopPrank();

        assertEq(nft.ownerOf(1), user1);
    }

    function test_withdrawERC20FailedDueToNotOwner() public {
        _usersBuyingNFT();
        vm.startPrank(user1);
        vm.expectRevert();
        nft.withdrawERC20();
        vm.stopPrank();
    }

    function test_withdrawERC20() public {
        _usersBuyingNFT();

        vm.startPrank(owner);
        nft.withdrawERC20();

        vm.assertEq(token.balanceOf(owner), 1_000_000 ether - 1000 ether - 1000 ether + 20 ether);
    }

    function _usersBuyingNFT() internal {
        vm.startPrank(user1);
        token.approve(address(nft), 10 ether);
        nft.mint();
        vm.stopPrank();

        vm.startPrank(user2);
        token.approve(address(nft), 10 ether);
        nft.mint();
        vm.stopPrank();
    }
}
