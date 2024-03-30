// SPDX-License-Identifier: MIT
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

    uint256 constant AMOUNT = 10_000_000; // 10 USD
    uint256 constant SENDER_PRIVATE_KEY = 2222;
    uint256 constant FEE = 10;
    uint256 constant initial_suppy = 1e12;
    uint256 deadline = block.timestamp + 60;

    function setUp() public virtual {
        bob = vm.addr(SENDER_PRIVATE_KEY);
        vm.prank(bob);
        usdc = new TestUSDC();
        gasless_sender = new Sender(address(this), address(usdc));
    }

    function testSent() public {
        uint256 amountLeft = initial_suppy - AMOUNT;

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

    function testRevert_OnlyGelatoRelayERC2771() public {
        //prepare typed message
        bytes32 permitHash = _getPermitHash(bob, address(gasless_sender), AMOUNT, usdc.nonces(bob), deadline);

        //signed typed message
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(SENDER_PRIVATE_KEY, permitHash);

        // maria trying to be the msg.sender
        vm.prank(maria);
        vm.expectRevert(Sender.OnlyGelatoRelayERC2771.selector);
        gasless_sender.send(bob, maria, AMOUNT, deadline, v, r, s);
    }

    function testRevert_InvalidSenderAddress() public {
        //prepare typed message
        bytes32 permitHash = _getPermitHash(bob, address(gasless_sender), AMOUNT, usdc.nonces(bob), deadline);

        //signed typed message
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(SENDER_PRIVATE_KEY, permitHash);

        vm.expectRevert(Sender.InvalidSenderAddress.selector);
        gasless_sender.send(address(0), maria, AMOUNT, deadline, v, r, s);
    }

    function testRevert_InvalidReceiverAddress() public {
        //prepare typed message
        bytes32 permitHash = _getPermitHash(bob, address(gasless_sender), AMOUNT, usdc.nonces(bob), deadline);

        //signed typed message
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(SENDER_PRIVATE_KEY, permitHash);
        vm.expectRevert(Sender.InvalidReceiverAddress.selector);
        gasless_sender.send(bob, address(0), AMOUNT, deadline, v, r, s);
    }

    function testRevert_TransferAmount() public {
        //prepare typed message
        bytes32 permitHash = _getPermitHash(bob, address(gasless_sender), AMOUNT, usdc.nonces(bob), deadline);

        //signed typed message
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(SENDER_PRIVATE_KEY, permitHash);
        vm.expectRevert(Sender.TransferAmountMustBeGreaterThanZero.selector);
        gasless_sender.send(bob, maria, 0, deadline, v, r, s);
    }

    function _getPermitHash(
        address _owner,
        address _spender,
        uint256 _value,
        uint256 _nonce,
        uint256 _deadline
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
                        _owner,
                        _spender,
                        _value,
                        _nonce,
                        _deadline
                    )
                )
            )
        );
    }
}
