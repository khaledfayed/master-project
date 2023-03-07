// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;
/**
 *Submitted for verification at Etherscan.io on 2016-03-24
*/

contract HonestDice {
	
	event Bet(address indexed user, uint blocknum, uint256 amount, uint chance);
	event Won(address indexed user, uint256 amount, uint chance);
	
	struct Roll {
		uint256 value;
		uint chance;
		uint blocknum;
		bytes32 secretHash;
		bytes32 serverSeed;
	}
	
	uint betsLocked;
	address owner;
	address feed;				   
	uint256 minimumBet = 1 * 1000000000000000000; // 1 Ether
	uint256 constant maxPayout = 5; // 5% of bankroll
	uint constant seedCost = 100000000000000000; // This is the cost of supplyin the server seed, deduct it;
	mapping (address => Roll) rolls;
	uint constant timeout = 20; // 5 Minutes
    uint256 max = 2**256 -1;
	
	constructor (){
		owner = msg.sender;
		feed = msg.sender;
	}
	//
	function roll(uint chance, bytes32 secretHash) payable public{
		if (chance < 1 || chance > 255 || msg.value < minimumBet || calcWinnings(msg.value, chance) > getMaxPayout() || betsLocked != 0) { 
			payable(msg.sender).transfer(msg.value); // Refund
			return;
		}
		rolls[msg.sender] = Roll(msg.value, chance, block.number, secretHash, 0);
		emit Bet(msg.sender, block.number, msg.value, chance);
	}
	
	function serverSeed(address user, bytes32 seed) public{
		// The server calls this with a random seed
		require(msg.sender == feed && seed != 0); //require that seed not equal zero
		if (rolls[user].serverSeed != 0) return;
		rolls[user].serverSeed = seed;
	}
	//
	function hashTo256(bytes32 _hash) public pure returns (uint _r){
		// Returns a number between 0 - 255 from a hash
		return uint(_hash) & 0xff;
	}
	
	function hash(bytes32 input) public pure returns (uint _r) {
		// Simple sha3 hash. Not to be called via the blockchain
		return uint(keccak256(abi.encodePacked(input))); 
	}
	
	function isReady() public view returns (bool _r) {
		return isReadyFor(msg.sender);
	}
	//
	function isReadyFor(address _user) public view returns (bool _r){
		Roll memory r = rolls[_user];
		if (r.serverSeed == 0) return false;
		return true;
	}
	
	function getResult(bytes32 secret) public view returns (uint _r){
		// Get the result number of the roll
		Roll memory r = rolls[msg.sender];
		require(r.serverSeed != 0);
		require(keccak256(abi.encodePacked(secret)) == r.secretHash);
		return hashTo256(keccak256(abi.encodePacked(secret, r.serverSeed)));
	}
	
	function didWin(bytes32 secret) public view returns (bool _r) {
		// Returns if the player won or not
		Roll memory r = rolls[msg.sender];
		require(r.serverSeed != 0);
		require(keccak256(abi.encodePacked(secret)) == r.secretHash);
		if (hashTo256(keccak256(abi.encodePacked(secret, r.serverSeed))) < r.chance) { // Winner
			return true;
		}
		return false;
	}
	
	function calcWinnings(uint256 value, uint chance) public pure returns (uint256 _r) {
		// 1% house edge
        // require(value < max);
        // require(chance < max);
        // require(chance > 0);
		return (value * 99 / 100) * 256 / chance;
	}
	//
	function getMaxPayout() public view returns (uint256 _r) {
		return address(this).balance * maxPayout / 100;
	}
	
	function claim(bytes memory secret) public{
		Roll memory r = rolls[msg.sender];
		address feedPre = feed;
		require(r.serverSeed != 0 && sha256(secret) == r.secretHash);
		if (hashTo256(sha256(abi.encodePacked(secret, r.serverSeed))) < r.chance) { // Winner
			msg.sender.call{value: (calcWinnings(r.value, r.chance) - seedCost)}("");
			emit Won(msg.sender, r.value, r.chance);
		}
		assert(feed == feedPre);
		delete rolls[msg.sender];
	}
	
	function canClaimTimeout() public view returns (bool _r) {
		Roll memory r = rolls[msg.sender];
		if (r.serverSeed != 0) return false;
		if (r.value <= 0) return false;
		if (block.number < r.blocknum + timeout) return false;
		return true;
	}
	//
	function claimTimeout() public{
		// Get your monies back if the server isn't responding with a seed
		require(canClaimTimeout());
		Roll memory r = rolls[msg.sender];
		payable(msg.sender).transfer(r.value);
		delete rolls[msg.sender];
	}
	
	function getMinimumBet() public view returns (uint _r) {
		return minimumBet;
	}
	
	function getBankroll() public view returns (uint256 _r) {
		return address(this).balance;
	}
	
	function getBetsLocked() public view returns (uint _r) {
		return betsLocked;
	}
	//
	function setFeed(address newFeed) public{
		// require(msg.sender == owner);
		feed = newFeed;
	}
	//
	function lockBetsForWithdraw() public{
		require(msg.sender == owner);
		betsLocked = block.number;
	}
	
	function unlockBets() public{
		require(msg.sender == owner);
		betsLocked = 0;
	}
	
	function withdraw(uint amount) public{
		require(msg.sender == owner);
		if (betsLocked == 0 || block.number < betsLocked + 5760) return;
		payable(address(owner)).transfer(amount);
	}
}