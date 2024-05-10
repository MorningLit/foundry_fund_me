// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/FundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_ETH = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    function setUp() external {
        // fundMe = new FundMe();
        fundMe = new DeployFundMe().run();
        vm.deal(USER, STARTING_BALANCE);
    }
    function test1() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }
    function test2() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }
    function test3() public view {
        assertEq(fundMe.getVersion(), 4);
    }
    function test4() public {
        vm.expectRevert();
        fundMe.fund();
    }
    modifier fund() {
        vm.prank(USER);
        fundMe.fund{value: SEND_ETH}();
        _;
    }
    function test5() public fund {
        uint256 balance = fundMe.getAddressToAmountFunded(USER);
        assertEq(balance, SEND_ETH);
    }
    function test6() public fund {
        address fundAddress = fundMe.getFunder(0);
        assertEq(fundAddress, USER);
    }
    function test7() public fund {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }
    function test8() public fund {
        uint256 ownerBalance = fundMe.getOwner().balance;
        uint256 initialBalance = address(fundMe).balance;

        // uint256 gasStart = gasleft()
        // vm.txGasPrice(1);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        // uint256 gasEnd = gasleft()
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice

        uint256 afterOwnerBalance = fundMe.getOwner().balance;
        uint256 afterBalance = address(fundMe).balance;
        assertEq(initialBalance + ownerBalance, afterOwnerBalance);
        assertEq(afterBalance, 0);
    }
    function test9() public {
        uint160 numberOfFunders = 10;
        for (uint160 i = 1; i < numberOfFunders; i++) {
            hoax(address(i), SEND_ETH);
            fundMe.fund{value: SEND_ETH}();
        }

        uint256 ownerBalance = fundMe.getOwner().balance;
        uint256 initialBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 afterOwnerBalance = fundMe.getOwner().balance;
        uint256 afterBalance = address(fundMe).balance;
        assertEq(initialBalance + ownerBalance, afterOwnerBalance);
        assertEq(afterBalance, 0);
    }
}
