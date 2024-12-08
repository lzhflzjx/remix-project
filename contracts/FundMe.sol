// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// 3.在锁定期内达到目标值，生产可以提款
// 4.在锁定期内没有达到目标值，投资人可以退款

contract FundMe {
    mapping(address => uint256) public funderToAmount;

    uint256 MINMUM_VALUE = 100 * 10**18; //限定收款最小值 wei

    AggregatorV3Interface internal dataFeed; 

    uint256 constant TARGET = 1000 * 10 ** 18;

    address owner;

    constructor() {
        // sepolia-testnet
        dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        owner = msg.sender;
    }

    // 1.创建一个收款函数
    function fund() external payable {
        // payable：收款关键字
        require(convertEthToUsd(msg.value) >= MINMUM_VALUE, "send more ETH");
        // 2.记录一个投资人并且查看
        funderToAmount[msg.sender] = msg.value;
    }

    /**
     * Returns the latest answer.
     */
    function getChainlinkDataFeedLatestAnswer() public view returns (int256) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }

    function convertEthToUsd(uint256 ethAmount) internal view  returns(uint256){
        // (ETH amount) * (ETH price) = (ETH value)
        uint256 ethPrice = uint256(getChainlinkDataFeedLatestAnswer());
        // ethAmount 单位是wei； ethPrice的精确度 precision 10**8
        return ethAmount * ethPrice / (10 ** 8);
    }

    function getFund() external view {
         require(convertEthToUsd(address(this).balance) >= TARGET,"target is not reached");
    }

    function transferOwnerShip(address newOwner) public {
        require(msg.sender == owner,"this function can only be called by owner");
        owner = newOwner;
        require(convertEthToUsd(address(this).balance) >= TARGET,"target is not reached");
    }
}
