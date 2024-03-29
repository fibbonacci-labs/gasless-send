// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

interface IERC20Permit {
    function permit(
        // sender
        address owner,
        // on behalf of ...
        address spender,
        // amount
        uint256 value,
        // permit valid for
        uint256 deadline,
        // signature -> v, r, s
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external;

    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
