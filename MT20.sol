// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MT20 is ERC20, ERC20Burnable, ERC20Permit, Ownable  {
    mapping(address => uint256) public lockExpiry;
    
    constructor() ERC20("POLYGONTC", "NTC") ERC20Permit("POLYGONTC") Ownable(msg.sender){
        _mint(msg.sender, 1000 * 10 ** decimals());
    }

      function airdrop(address[] calldata recipients, uint256 amount) external onlyOwner {
        for (uint i = 0; i < recipients.length; i++) {
            _transfer(msg.sender, recipients[i], amount);
        }
    }
    function lockTokens(address account, uint256 timeInSeconds) external onlyOwner {
        lockExpiry[account] = block.timestamp + timeInSeconds;
    }
}
