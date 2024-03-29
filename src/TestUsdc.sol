// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

// Fake USDC for testnet and local development.
contract TestUSDC is ERC20, ERC20Permit {
    constructor() ERC20("testUSDC", "USDC") ERC20Permit("testUSDC") {
        _mint(msg.sender, 1e12); // $1,000,000
    }

    // USDC has 6 decimals
    function decimals() public pure virtual override returns (uint8) {
        return 6;
    }
}
