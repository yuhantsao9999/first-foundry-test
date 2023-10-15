// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WrarpEther is ERC20("WrapEther", "WETH") {
    // init: user 1 ether, 0 weth (WETH.balanceOf(user) = 0)
    // user call deposit with 1 ether
    // after: user 0 ether,

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    function deposit() external payable {
        _mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external payable {
        require(balanceOf(msg.sender) >= amount, "Not enough WETH balance");
        _burn(msg.sender, amount);
        (bool isSuccess, ) = payable(msg.sender).call{value: amount}("");
        require(isSuccess, "Withdraw Failed");
        emit Withdraw(msg.sender, msg.value);
    }
}
