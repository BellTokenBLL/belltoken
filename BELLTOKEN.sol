// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.7.0
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BELLTOKEN is ERC20 {
    constructor(address recipient) ERC20("BELL TOKEN", "BLL") {
        _mint(recipient, 1000000000 * 10 ** decimals());
    }
}
