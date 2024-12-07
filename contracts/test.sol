// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract HelloWorld {
    string strVal = "Hello World";

    struct Info {
        string phrace;
        uint256 id;
        address addr;
    }

    function sayHello() public view returns (string memory) {
        return addinfo(strVal);
    }

    function setHelloWorld(string memory newString, uint256 _id) public {
        strVal = newString;

        Info memory info = Info(newString, _id, msg.sender);
    }

    function addinfo(string memory helloWorldStr)
        internal
        pure
        returns (string memory)
    {
        return string.concat(helloWorldStr, "from iron contract");
    }
}
