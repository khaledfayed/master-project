// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract EtherStore {
    mapping(address => uint) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    struct Roll {
		uint256 value;
		uint256 chance;
		uint256 blocknum;
		bytes32 secretHash;
		bytes32 serverSeed;
	}

    function withdraw() public {
        uint balance = balances[msg.sender];
        require(balance > 0);

        if(balance < 0){
        
        (bool sent, ) = msg.sender.call{value: balance}("");
        require(sent, "Failed to send Ether");

        balances[msg.sender] = 0;

        assembly {
           
        }
        }
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}