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
    // 个性化ERC20代码
    // mint和claim的调用时机：众筹时间结束以后，并且owner调用了getFund函
    // 数并且提取了所有ETH以后，其他参与者才可以mitt Erc20的通证作为凭证，然后
    // 最后所有的凭证进行claim也就是进行商品的兑换
    function mint(uint256 amountToMint) public  {
        require((fundMe.funderToAmount(msg.sender) >= amountToMint),"you can not mint this many tokens");
        require(fundMe.getFundSuccess(),"The fundMe is not completed yet");//如果一个变量只作为一个状态返回，默认为getter函数（当属性为public时）
        _mint(msg.sender,amountToMint);
        fundMe.setFunderToAmount(msg.sender, amountToMint);
    }
    // 兑换
    function claim(uint256 amountToClaim) public {
        // if complete claim(如果完成兑换)
        // claim之前判断msg.sender是否有足够的Erc20通证
        require(balanceOf(msg.sender) >= amountToClaim,"you dont have enough Erc20 tokens");
        require(fundMe.getFundSuccess(),"The fundMe is not completed yet");
        /** to add 去兑换，需要有具体使用场景*/
        // burn amountToClaim Tokens(销毁掉兑换过的tokens)
        _burn(msg.sender,amountToClaim);
    }
}