// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import { ERC2771Context } from "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { ERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract Sender is ERC2771Context, ReentrancyGuard {
    ERC20Permit public token;

    error OnlyGelatoRelayERC2771();
    error InvalidSenderAddress();
    error InvalidReceiverAddress();
    error TransferAmountMustBeGreaterThanZero();

    event TokenTransferred(address indexed sender, address indexed receiver, uint256 amount);

    // ERC2771Context: setting the immutable trustedForwarder variable
    constructor(address trustedForwarder, address _token) ERC2771Context(trustedForwarder) {
        token = ERC20Permit(_token);
    }

    function send(
        address sender,
        address receiver,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
        nonReentrant
    {
        if (!isTrustedForwarder(msg.sender)) revert OnlyGelatoRelayERC2771();
        if (sender == address(0)) revert InvalidSenderAddress();
        if (receiver == address(0)) revert InvalidReceiverAddress();
        if (amount <= 0) revert TransferAmountMustBeGreaterThanZero();

        // Allow someone to spend tokens on behalf of the sender
        token.permit(sender, address(this), amount, deadline, v, r, s);

        // Transfer an amount of tokens from one person to another.
        token.transferFrom(sender, receiver, amount);

        emit TokenTransferred(sender, receiver, amount);
    }
}
