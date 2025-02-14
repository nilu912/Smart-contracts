// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract bankAcc{
    struct Account{
        address owner;
        uint balance;
        bool isActive;
    }
    mapping(uint=>Account) private accounts;
    uint private nextAccountId=1;
    modifier isOwner(uint _accId){
        require(accounts[_accId].owner==msg.sender,"Not owner");
        _;
    }
    modifier accActive(uint _accId){
        require(accounts[_accId].isActive,"Account is not activated!");
        _;
    }

    function addUser() public returns (uint){
        uint accountId = nextAccountId++;
        accounts[accountId] = Account({
            owner: msg.sender,
            balance: 0,
            isActive: true
        });
        return accountId;
    }
    function getBal(uint accountId) public isOwner(accountId) view returns(uint){
        return accounts[accountId].balance;
    }
    function deposite(uint accountId, uint _bal) public isOwner(accountId) accActive(accountId){
        // require(accounts[accountId].isActive==true,"Account is not actived");
        accounts[accountId].balance+=_bal;
    }
    function widraw(uint accountId, uint _bal) public isOwner(accountId) accActive(accountId) returns(uint){
        require(accounts[accountId].balance>=_bal,"Not sufficient balance");
        accounts[accountId].balance-=_bal;
        return accounts[accountId].balance;
    }
    function deavtivateAcc(uint accountId) public isOwner(accountId) returns (string memory){
        accounts[accountId].isActive=false;
        return "Account has been deActivated successfully";
    } 
    function activateAcc(uint accountId) public isOwner(accountId) returns (string memory){
        accounts[accountId].isActive=true;
        return "Account has been Activated successfully";
    }
    function transferBal(uint from,uint to,uint amm) public isOwner(from) isOwner(to) accActive(from) accActive(to) returns (uint){
        require(accounts[from].balance>=amm, "Not sufficient ammount!");
        accounts[from].balance-=amm;
        accounts[to].balance+=amm;
        return accounts[from].balance;
    }
}