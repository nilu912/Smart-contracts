// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract smartBank{
    mapping (address => uint) private balance;
    address owner;
    constructor(){
        owner=msg.sender;
    }
    event Deposited(address indexed from, uint amount);
    event Withdrawed(address indexed from, uint amount);
    event Transfered(address indexed from, address to, uint amount);

    function deposit() public payable{
        require(msg.value > 0, "No amount provided");
        balance[msg.sender] += msg.value;

        emit Deposited(msg.sender, msg.value);
    }
    function withdraw(uint amount) public {
        require(balance[msg.sender] > amount, "Insufficient funds!");
        balance[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);

        emit Withdrawed(msg.sender, amount);
    }
    function transfer(address payable to, uint amount) public {
        require(balance[msg.sender] >= amount, "Insufficient funds!");
        balance[msg.sender] -= amount;
        balance[to] += amount;
        emit Transfered(msg.sender, to, amount);
    }
    function getBalance() public view returns(uint){
        return balance[msg.sender];
    }
    function getContractBalance() public view returns(uint){
        require(msg.sender == owner, "Not allowed for this action");
        return address(this).balance;
    }
}
