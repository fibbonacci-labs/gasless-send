// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import { PRBTest } from "@prb/test/src/PRBTest.sol";
import { console2 } from "forge-std/src/console2.sol";
import { StdCheats } from "forge-std/src/StdCheats.sol";

import { Sender } from "../src/Sender.sol";
import { TestUSDC } from "../src/TestUsdc.sol";
import { IERC20Permit } from "../src/interfaces/IERC20Permit.sol";

contract SenderTest is PRBTest, StdCheats {
    Sender gasless_sender;
    TestUSDC usdc;

    address bob;
    address maria = address(2);

    uint256 constant AMOUNT = 10000000; // 10 USD
    uint256 constant SENDER_PRIVATE_KEY = 2222;
    uint256 constant FEE = 10;
    uint constant initial_suppy = 1e12;

    function setUp() public virtual {
        bob = vm.addr(SENDER_PRIVATE_KEY);
        vm.prank(bob);
        usdc = new TestUSDC();
        gasless_sender = new Sender(address(this), address(usdc));
    }

    function testSent() public {
        uint amountLeft = initial_suppy - AMOUNT;
        uint256 deadline = block.timestamp + 60;
        //prepare typed message
        bytes32 permitHash = _getPermitHash(bob, address(gasless_sender), AMOUNT, usdc.nonces(bob), deadline);

        //signed typed message
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(SENDER_PRIVATE_KEY, permitHash);
        //execute sent
        gasless_sender.send(bob, maria, AMOUNT, deadline, v, r, s);

        //bob balance should be left amount 
        assertEq(usdc.balanceOf(bob), amountLeft, "owner balance");
        //maria balance should be amount due from bob
        assertEq(usdc.balanceOf(maria), AMOUNT, "receiver balance");
    }

    function _getPermitHash(
        address owner,
        address spender,
        uint256 value,
        uint256 nonce,
        uint256 deadline
    )
        private
        view
        returns (bytes32)
    {
        return keccak256(
            abi.encodePacked(
                "\x19\x01",
                usdc.DOMAIN_SEPARATOR(),
                keccak256(
                    abi.encode(
                        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                        owner,
                        spender,
                        value,
                        nonce,
                        deadline
                    )
                )
            )
        );
    }
}
