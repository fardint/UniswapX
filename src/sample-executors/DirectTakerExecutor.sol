// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {IReactorCallback} from "../interfaces/IReactorCallback.sol";
import {Output} from "../interfaces/ReactorStructs.sol";

contract DirectTakerExecutor is IReactorCallback {
    function reactorCallback(
        Output[] calldata outputs,
        bytes calldata fillData
    ) external {
        (address taker, address inputToken, uint256 inputAmount, address reactor) = abi.decode(
            fillData, (address, address, uint256, address)
        );
        uint256 totalOutputAmount;
        // transfer output tokens from taker to this
        for (uint256 i = 0; i < outputs.length; i++) {
            Output memory output = outputs[i];
            ERC20(output.token).transferFrom(taker, address(this), output.amount);
            totalOutputAmount += output.amount;
        }
        // Assumed that all outputs are of the same token
        ERC20(outputs[0].token).approve(reactor, totalOutputAmount);
        // transfer input tokens from this to taker
        ERC20(inputToken).transfer(taker, inputAmount);
    }
}