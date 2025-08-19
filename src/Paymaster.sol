//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@account-abstraction/contracts/interfaces/IPaymaster.sol";

contract Paymaster is IPaymaster{

    function validatePaymasterUserOp(UserOperation calldata userOp, bytes32 userOpHash, uint256 maxCost)
        external returns (bytes memory context, uint256 validationData){

        
            context = "";
            validationData = 0;
    }



    function postOp(PostOpMode mode, bytes calldata context, uint256 actualGasCost) external{
        
    }

    }

