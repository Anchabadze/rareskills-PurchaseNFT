// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title Purchase NFT with ERC20 tokens
 * @notice Rareskills beginner solidity projects list
 * @author Zurab Anchabadze (https://x.com/anchabadze)
 */
contract PurchaseNFT is ERC721("myNFT", "myNFT"), Ownable(msg.sender) {
    using SafeERC20 for IERC20;

    IERC20 public paymentToken;
    uint256 public mintPrice;
    uint256 public curSupply = 1;
    uint256 public constant maxSupply = 1000;

    constructor(address _paymentToken, uint256 _mintPrice) {
        paymentToken = IERC20(_paymentToken);
        mintPrice = _mintPrice;
    }

    function mint() external {
        require(curSupply < maxSupply, "max supply reached");
        require(paymentToken.balanceOf(msg.sender) >= mintPrice, "not enough tokens");
        paymentToken.safeTransferFrom(msg.sender, address(this), mintPrice);
        _safeMint(msg.sender, curSupply);
        curSupply += 1;
    }

    function setMintPrice(uint256 _newMintPrice) external onlyOwner {
        mintPrice = _newMintPrice;
    }

    function withdrawERC20() external onlyOwner {
        paymentToken.safeTransfer(owner(), paymentToken.balanceOf(address(this)));
    }

    function getPrice() external view returns (uint256) {
        return mintPrice;
    }

    function getRemainingSupply() external view returns (uint256) {
        return maxSupply - curSupply;
    }
}
