// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {UserAccount, AccountFactory} from "../src/Account.sol";
import "@account-abstraction/contracts/core/EntryPoint.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {Paymaster} from "../src/Paymaster.sol";

contract CounterTest is Test {

    EntryPoint public entryPoint;
    AccountFactory public accountFactory;
    address public owner;
    Paymaster public paymaster;
    uint256 ownerPrivateKey;


    function setUp() public {
        entryPoint = new EntryPoint();
        accountFactory = new AccountFactory();
        ownerPrivateKey = 0x1234567890123456789012345678901234567890123456789012345678901234;
        owner = vm.addr(ownerPrivateKey);
        paymaster = new Paymaster();
        vm.deal(address(paymaster), 10000 ether);
    }

    function test_paymaster() public {
        vm.startPrank(address(paymaster));
        entryPoint.depositTo{value: 100 ether}(address(paymaster));
        vm.stopPrank();

        bytes memory initCode = abi.encodePacked(address(accountFactory), abi.encodeWithSelector(AccountFactory.createAccount.selector, owner));
        address sender = vm.computeCreateAddress(address(accountFactory), 1);

        UserOperation memory userOp = UserOperation({
            sender: sender,
            nonce: entryPoint.getNonce(address(sender), 0),
            initCode: initCode,
            callData: abi.encodeWithSelector(UserAccount.execute.selector),
            callGasLimit: 200_000,
            verificationGasLimit: 2_000_000,
            preVerificationGas: 50_000,
            maxFeePerGas: 10_000_000_000,
            maxPriorityFeePerGas: 10_000_000_000,
            paymasterAndData: abi.encodePacked(address(paymaster)),
            signature: "0x"
        });

        bytes32 userOpHash = entryPoint.getUserOpHash(userOp);

        bytes32 ethSignedMessageHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", userOpHash)
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, ethSignedMessageHash);
        
        // 4. Encode signature
        userOp.signature = abi.encodePacked(r, s, v);


        UserOperation[] memory userOps = new UserOperation[](1);
        userOps[0] = userOp;

        entryPoint.handleOps(userOps, payable(address(1)));
        console.log(UserAccount(sender).count());

        userOp.nonce = entryPoint.getNonce(address(sender), 0);


    }


    // function test_userOp() public {
    //     bytes memory initCode = abi.encodePacked(address(accountFactory), abi.encodeWithSelector(AccountFactory.createAccount.selector, owner));
    //     address sender = vm.computeCreateAddress(address(accountFactory), 1);
    //     UserOperation memory userOp = UserOperation({
    //         sender: sender,
    //         nonce: entryPoint.getNonce(sender, 0),
    //         initCode: initCode,
    //         callData: abi.encodeWithSelector(UserAccount.execute.selector),
    //         callGasLimit:200_000,
    //         verificationGasLimit:2_00_00_000,
    //         preVerificationGas:50_000,
    //         maxFeePerGas:10_000_000_000,
    //         maxPriorityFeePerGas:10_000_000_000,
    //         paymasterAndData:"",
    //         signature:"0x"
    //     });

    //     UserOperation[] memory userOps = new UserOperation[](1);
    //     userOps[0]=userOp;

    //     vm.startPrank(paymaster);
    //     entryPoint.depositTo{value: 1 ether}(sender);
    //     entryPoint.handleOps(userOps, payable(paymaster));

    //     console.log(UserAccount(sender).count());

    //     UserOperation memory userOp2 = UserOperation({
    //         sender: sender,
    //         nonce: entryPoint.getNonce(sender, 0),
    //         initCode:"",
    //         callData: abi.encodeWithSelector(UserAccount.execute.selector),
    //         callGasLimit:200_000,
    //         verificationGasLimit:2_00_00_000,
    //         preVerificationGas:50_000,
    //         maxFeePerGas:10_000_000_000,
    //         maxPriorityFeePerGas:10_000_000_000,
    //         paymasterAndData:"",
    //         signature:"0x"
    //     });

    //     userOps[0]=userOp2;
    //     entryPoint.handleOps(userOps, payable(paymaster));
    //     // entryPoint.handleOps(userOps, payable(paymaster));

    //     console.log(UserAccount(sender).count());
    // }


}
