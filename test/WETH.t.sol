//SPDX-License-Identifier:UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {WrarpEther} from "../src/WETH.sol";

contract WETHtest is Test {
    WrarpEther public wEth;
    address user1;
    address user2;
    address user3;

    function setUp() public {
        wEth = new WrarpEther();
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        user3 = makeAddr("user3");
        deal(user1, 1 ether);
        deal(user2, 1 ether);
        deal(user3, 1 ether);
    }

    //測項 1: deposit 應該將與 msg.value 相等的 ERC20 token mint 給 user
    // user call deposit function with 1 ether value
    // user will get 1 ether erc20 weth amount
    function test_Deposit_should_mint_correct_amount() public {
        vm.startPrank(user1);
        wEth.deposit{value: 1 ether}();
        vm.stopPrank();

        assertEq(user1.balance, 0);
        assertEq(wEth.balanceOf(user1), 1 ether);
    }

    //測項 2: deposit 應該將 msg.value 的 ether 轉入合約
    function test_Deposit_should_transfer_correct_ether_amount() public {
        vm.startPrank(user1);
        wEth.deposit{value: 1 ether}();
        vm.stopPrank();
        assertEq(address(wEth).balance, 1 ether);
    }

    //測項 3: deposit 應該要 emit Deposit event
    event Deposit(address indexed account, uint amount);

    function test_DepositEvent() external {
        vm.startPrank(user1);

        vm.expectEmit(true, true, false, false);
        emit Deposit(user1, 1 ether);

        wEth.deposit{value: 1 ether}();
        vm.stopPrank();
    }

    //測項 4: withdraw 應該要 burn 掉與 input parameters 一樣的 erc20 token
    function test_withdraw_erc20() public {
        vm.startPrank(user1);
        wEth.deposit{value: 1 ether}();
        wEth.withdraw(0.4 ether);
        vm.stopPrank();

        assertEq(0.4 ether, 1 ether - wEth.balanceOf(user1));
    }

    //測項 5: withdraw 應該將 burn 掉的 erc20 換成 ether 轉給 user
    function test_withdraw_ether() public {
        vm.startPrank(user1);

        // weth balance (0)
        // user balance (1 ether)
        // user weth balanceOf (0)

        wEth.deposit{value: 1 ether}();

        // weth balance (1 ether)
        // user balance (0)
        // user weth balanceOf (1 ether)

        wEth.withdraw(0.4 ether);

        // weth balance (0.6 ether)
        // user balance (0.4 ether)
        // user weth balanceOf (0.6 ether)

        vm.stopPrank();

        assertEq(0.4 ether, user1.balance);
        assertEq(0.6 ether, address(wEth).balance);
    }

    // test case 6: withdraw 應該要 emit Withdraw event
    event Withdraw(address indexed account, uint amount);

    function test_WithdrawEvent() external {
        vm.startPrank(user1);

        wEth.deposit{value: 1 ether}();
        vm.expectEmit(true, true, false, false);
        emit Withdraw(user1, 1 ether);
        wEth.withdraw(1 ether);

        vm.stopPrank();
    }

    // 測項 7: transfer 應該要將 erc20 token 轉給別人
    function test_transfer() public {
        vm.startPrank(user1);
        //user1 deposit 1 weth
        wEth.deposit{value: 1 ether}();
        //user1 transfer 0.4 ether to user2
        wEth.transfer(user2, 0.4 ether);
        vm.stopPrank();
        //user1 weth balanceOf 0.6
        assertEq(0.6 ether, wEth.balanceOf(user1));
        //user2 weth balanceOf 0.4
        assertEq(0.4 ether, wEth.balanceOf(user2));
    }

    // 測項 8: approve 應該要給他人 allowance
    function test_approve() public {
        vm.startPrank(user1);
        //user1 deposit 1 ether
        wEth.deposit{value: 1 ether}();
        //user1 approve 0.4 ether to user2
        wEth.approve(user2, 0.4 ether);
        vm.stopPrank();

        //equal 0.4 = allowance(user1,user2)
        assertEq(0.4 ether, wEth.allowance(user1, user2));
    }

    // 測項 9: transferFrom 應該要可以使用他人的 allowance
    function test_transferFrom() public {
        vm.startPrank(user1);
        //user1 deposit 1 ether
        wEth.deposit{value: 1 ether}();
        //user1 approve 0.4 ether to user2
        wEth.approve(user2, 0.4 ether);
        vm.stopPrank();

        vm.startPrank(user2);
        //transferFrom(user1, user2, 0.1)
        wEth.transferFrom(user1, user3, 0.1 ether);
        vm.stopPrank();

        console.log("user1 wEth:", wEth.balanceOf(user1));
        console.log("user3 wEth:", wEth.balanceOf(user3));
        //equal 0.3 = allowance(user1,user2)
        assertEq(0.3 ether, wEth.allowance(user1, user2));
    }

    // 測項 10: transferFrom 後應該要減除用完的 allowance
    function test_transferFrom2() public {
        vm.startPrank(user1);
        //user1 deposit 1 ether
        wEth.deposit{value: 1 ether}();
        //user1 approve 0.4 ether to user2
        wEth.approve(user2, 0.4 ether);
        vm.stopPrank();

        vm.startPrank(user2);
        //transferFrom(user1, user2, 0.1)
        wEth.transferFrom(user1, user3, 0.1 ether);
        vm.stopPrank();

        //equal 0.3 = allowance(user1,user2)
        assertEq(0.3 ether, wEth.allowance(user1, user2));
    }
}
