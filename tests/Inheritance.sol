// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// 继承
abstract contract Parent {
    uint256 public a;
    function addOne() public {
        a++;
    }

    function addTwo() public virtual {
        a +=2;
    }
}

contract Child is Parent {
    function addTwo() public  override {
        a += 3;
    }
}