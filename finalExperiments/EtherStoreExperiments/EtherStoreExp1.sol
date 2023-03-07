// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract EtherStore {
    mapping(address => uint) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public {
        uint balance = balances[msg.sender];
        require(balance > 0);

        (bool sent, ) = msg.sender.call{value: balance}("");
        require(sent, "Failed to send Ether");

        assert(balance == balances[msg.sender]);

        balances[msg.sender] = 0;
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}