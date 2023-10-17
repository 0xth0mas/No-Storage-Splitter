//SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {ERC20} from './ERC20.sol';

contract TestERC20 is ERC20 {

    function name() public pure override returns(string memory) {
        return "Test";
    }

    function symbol() public pure override returns(string memory) {
        return "T";
    }

    function mintSome() external {
        _mint(msg.sender, 10 ether);
    }
}