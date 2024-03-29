// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {ERC2771Context} from "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Sender is ERC2771Context, ReentrancyGuard {
    ERC20Permit public token;

    event TokenTransferred(address indexed sender, address indexed receiver, uint256 amount);

    constructor(address trustedForwarder, ERC20Permit _token) ERC2771Context(trustedForwarder) {
        token = _token;
    }

    function send(
        address sender,
        address receiver,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external nonReentrant {
        require(isTrustedForwarder(msg.sender),"onlyGelatoRelayERC2771");
        require(sender != address(0), "Invalid sender address");
        require(receiver != address(0), "Invalid receiver address");
        require(amount > 0, "Transfer amount must be greater than zero");

        // Allow someone to spend tokens on behalf of the sender
        token.permit(sender, address(this), amount, deadline, v, r, s);

        // Transfer an amount of tokens from one person to another.
        token.transferFrom(sender, receiver, amount);

        emit TokenTransferred(sender, receiver, amount);
    }
}
