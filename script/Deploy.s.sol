// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.21 <0.9.0;

import { Sender } from "../src/Sender.sol";

import { BaseScript } from "./Base.s.sol";

contract Deploy is BaseScript {
    function run() public broadcast returns (Sender sender) {
        // trustedForwarder -> GelatoRelay1BalanceERC2771
        address relayer = 0xd8253782c45a12053594b9deB72d8e8aB2Fca54c;

        // usdc sepolia
        address usdc = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238;

        sender = new Sender(relayer, usdc);
    }
}
