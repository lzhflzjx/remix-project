// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// 继承
contract Parent {
    uint256 public a;
    function addOne() public {
        a++;
    }
}

contract Child is Parent {
    function addTwo() public {
        a +=2;
    }
}