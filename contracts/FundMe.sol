// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    mapping(address => uint256) public funderToAmount;

    uint256 MINMUM_VALUE = 10 * 10**18; //限定收款最小值 wei

    AggregatorV3Interface internal dataFeed;

    uint256 constant TARGET = 100 * 10**18;

    address public owner;
    // 时间锁
    // 开始锁定的时间
    uint256 deploymentTimestamp;
    // 锁定时长
    uint256 lockTime;

    address erc20Addr;

    constructor(uint256 _lockTime) {
        // sepolia-testnet
        dataFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        owner = msg.sender;
        // 当前区块的开始时间
        deploymentTimestamp = block.timestamp;
        // 用户输入的锁定时长
        lockTime = _lockTime;
    }

    /**
    1.创建一个收款函数
    */
    function fund() external payable {
        //  收款函数可执行时机必须小于deploymentTimestamp+lockTime
        require(
            block.timestamp < deploymentTimestamp + lockTime,
            "window is closed"
        );
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

    function convertEthToUsd(uint256 ethAmount)
        internal
        view
        returns (uint256)
    {
        // (ETH amount) * (ETH price) = (ETH value)
        uint256 ethPrice = uint256(getChainlinkDataFeedLatestAnswer());
        // ethAmount 单位是wei； ethPrice的精确度 precision 10**8
        return (ethAmount * ethPrice) / (10**8);
    }

    function transferOwnerShip(address newOwner) public onlyOwner{
        owner = newOwner;
    }

    // 3.在锁定期内达到目标值，生产可以提款
    function getFund() external windowClosed onlyOwner{
        require(
            convertEthToUsd(address(this).balance) >= TARGET,
            "target is not reached"
        );
        //  transfer 纯转账 transfer ETH  and revert if tx failed
        // payable(msg.sender).transfer(address(this).balance);
        // send  纯转账 transfer ETH  and return false if failed
        // bool success = payable(msg.sender).send(address(this).balance);
        // require(success, "tx failed");
        // call transfer ETH  with data return value of function and bool
        bool success;
        (success, ) = payable(msg.sender).call{value: address(this).balance}(
            ""
        );
        require(success, "transfer tx failed");

        funderToAmount[msg.sender] = 0;
    }

    // 4.在锁定期内没有达到目标值，投资人可以退款
    function reFund() external windowClosed {
        require(
            convertEthToUsd(address(this).balance) < TARGET,
            "target is reached"
        );

        uint256 amount = funderToAmount[msg.sender];
        require(amount != 0, "there is not fund for you");
        bool success;
        (success, ) = payable(msg.sender).call{
            value: funderToAmount[msg.sender]
        }("");
        require(success, "transfer tx failed");

        // 安全问题：退款后将余额置为0
        funderToAmount[msg.sender] = 0;
    }

    function setFunderToAmount(address funder,uint256 amountToUpdate) external {
        require(msg.sender == erc20Addr,"you do not have permission to call this function");
        funderToAmount[funder] = amountToUpdate;
    }

    function setErc20Addr(address _erc20Addr) public onlyOwner{
        erc20Addr = _erc20Addr;
    }
    // 修改器
    modifier windowClosed() {
        // 窗口关闭后才可提款
        require(
            block.timestamp >= deploymentTimestamp + lockTime,
            "window is not closed"
        );
        _; //下划线在require下面,表示先执行判断再执行后续代码
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "this function can only be called by owner"
        );
        _;
    }
}
