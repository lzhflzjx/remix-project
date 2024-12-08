// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// struct
// array
// mapping
contract HelloWorld {
    string strVal = "Hello World";

    struct Info {
        string phrace;
        uint256 id;
        address addr;
    }

    Info[] infos;

    mapping(uint256 => Info) infoMapping;

    function sayHello(uint256 _id) public view returns (string memory) {
        if (infoMapping[_id].addr == address(0x0)) {
            return addinfo(strVal);
        }
        
        return addinfo(infoMapping[_id].phrace);
    }

    function setHelloWorld(string memory newString, uint256 _id) public {
        Info memory info = Info(newString, _id, msg.sender);
        infoMapping[_id] = info;
    }

    function addinfo(string memory helloWorldStr)
        internal
        pure
        returns (string memory)
    {
        return string.concat(helloWorldStr, "from Spark contract");
    }
}
