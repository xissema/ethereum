// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract Refund is Ownable {
    
    function refundETH() external onlyOwner {
        payable(_msgSender()).transfer(
            address(this).balance
        );
    }

    function refundToken(IERC20 token) external onlyOwner {
        token.transfer(
            _msgSender(),
            token.balanceOf(
                address(this)
            )
        );
    }
}