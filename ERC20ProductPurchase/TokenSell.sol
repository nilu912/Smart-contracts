// SPDX-License-Identifier: MIT

pragma solidity ^0.8.27;

interface IERC20{
    function transferFrom(address from, address to, uint ammount) external;
    function decimals() external view returns(uint);
}

contract TokenSell{
    uint tokenPriceInWei = 1 ether;
    address tokenOwner;
    IERC20 token;

    constructor(address _token){
        tokenOwner = msg.sender;
        token = IERC20(_token);
    }
    modifier onlyOwner(){
        require(msg.sender == tokenOwner, "Sorry you are not Owner!");
        _;
    }
    function buyToken() public payable  {
        require(msg.value >= tokenPriceInWei, "Insufficient ammount for token!");
        uint TokenToTransfer = msg.value / tokenPriceInWei;
        uint returnableAmmount =  msg.value - TokenToTransfer * tokenPriceInWei;
        token.transferFrom(tokenOwner, msg.sender, TokenToTransfer * 10 ** token.decimals());
        payable(msg.sender).transfer(returnableAmmount);
    }
    function withdrawEth(uint _amm) public onlyOwner(){
        require(_amm >= address(this).balance);
        payable(tokenOwner).transfer(_amm);
    }
    function getBalance() public view returns(uint){
        return address(this).balance;
    }
}