// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7; //^所有高于这个版本的都可以编译

import {HelloWorld} from "./test.sol";

contract HelloWorldFactory {
    HelloWorld hw;

    HelloWorld[] hws;

    function createHelloWorld() public {
        hw = new HelloWorld();

        hws.push(hw);
    }

    function getHelloWorldByIndex(uint256 _index)
        public
        view
        returns (HelloWorld)
    {
        return hws[_index];
    }

    function callSayHelloFromFactory(uint256 _index, uint256 _id)
        public
        view
        returns (string memory)
    {
        return hws[_index].sayHello(_id);
    }

    function calSetHelloWorldFromFactory(
        uint256 _index,
        string memory newString,
        uint256 _id
    ) public {
        hws[_index].setHelloWorld(newString, _id);
    }
}
