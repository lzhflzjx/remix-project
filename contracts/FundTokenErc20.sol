// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// FundMe
// 1.让FundMe的参与者，基于mapping来领取相应数量的通证
// 2.让FundMe的参与者，transfer 通证
// 3.使用完成以后，需要burn通证
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {FundMe} from "./FundMe.sol";

contract FundTokenErc20 is ERC20 {
    FundMe fundMe;
    constructor(address fundMeAddr) ERC20("FundTokenErc20","FT"){
        fundMe = FundMe(fundMeAddr);
    }

    function mint(uint256 amountToMint) public  {
        require((fundMe.funderToAmount(msg.sender) >= amountToMint),"you can not mint this many tokens");
        _mint(msg.sender,amountToMint);
    }
    // 个性化ERC20代码
}