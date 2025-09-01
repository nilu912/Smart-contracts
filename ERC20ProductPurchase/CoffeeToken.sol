// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.4.0
pragma solidity ^0.8.27;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract coffeeToken is ERC20, ERC20Burnable, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    event BuyCoffee(address indexed receiver, address indexed buyer, uint ammount);

    constructor()
        ERC20("coffeeToken", "CTK")
    {
        _mint(msg.sender, 100 * 10 ** decimals());
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(BURNER_ROLE, msg.sender);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }
    function byCoffee() public {
        require(balanceOf(msg.sender) >= 1 * 10 ** decimals(), "Not enough balance");
        _burn(msg.sender, 1 * 10 ** decimals());
        emit BuyCoffee(msg.sender, msg.sender, 1 * 10 ** decimals());
    }
    function byCoffeeFrom(address account) public {
        require(balanceOf(account) >= 1 * 10 ** decimals(), "Not enough balance");
        require(allowance(account, _msgSender()) >= 1 * 10 ** decimals(), "Not enough allowance");
        _spendAllowance(account, _msgSender(), 1 * 10 ** decimals());
        _burn(account, 1 * 10 ** decimals());
        emit BuyCoffee(_msgSender(), account, 1 * 10 ** decimals());
    }
}