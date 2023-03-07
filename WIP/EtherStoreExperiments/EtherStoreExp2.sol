// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Lock {
    bool internal locked;

    modifier reentancyLock() {
        // require(!locked, "No re-entrancy");
        locked = true;
        bool lockedInitial = locked;
        _;
        assert(lockedInitial == locked);
        locked = false;
    }
}

contract EtherStore is Lock {
    mapping(address => uint) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public reentancyLock {
        uint balance = balances[msg.sender];
        require(balance > 0);

        (bool sent, ) = msg.sender.call{value: balance}("");
        require(sent, "Failed to send Ether");

        balances[msg.sender] = 0;
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}