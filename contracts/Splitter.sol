// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract Splitter {

    event SplitReleased(address token, uint256 totalAmount);

    constructor(address[] memory _recipients, uint256[] memory _shares) payable {
        bytes4 releaseSelector = Splitter.release.selector;
        bytes4 releaseTokenSelector = Splitter.releaseToken.selector;
        bytes4 recipientsSelector = Splitter.recipients.selector;
        bytes4 sharesSelector = Splitter.shares.selector;
        bytes4 totalSharesSelector = Splitter.totalShares.selector;
        bytes32 splitReleasedSelector = Splitter.SplitReleased.selector;
        assembly {
            let size := mload(_recipients)

            if iszero(size) {
                revert(0, 0)
            }
            if iszero(eq(size, mload(_shares))) {
                revert(0, 0)
            }
        }

        // 5935156009576013565B5959F35B60006000FDFB
        // 0000: 59 MSIZE (stack: 0)
        // 0001: 35 CALLDATALOAD (stack: first calldata word)
        // 0002: 15 ISZERO (stack: calldataiszero)
        // 0003: 6009 push jump dest if calldata is zero (receive/fallback) (stack: 9, calldataiszero)
        // 0005: 57 JUMPI dest condition (stack: empty)
        // 0006: 6013 push jump dest PC if calldata is nonzero (stack: 0x0D)
        // 0008: 56 JUMP (stack: empty)
        // 0009: 5B JUMPDEST (stack: empty)
        // 000a: 5959 MSIZE MSIZE (stack: 0, 0)
        // 000c: F3 RETURN
        // 000d: 5B JUMPDEST for generic revert
        // 000e: 60006000FD
        // 0013: 5B JUMPDEST (stack: empty)

        // FUNCTION SELECTOR - release, releaseToken, recipients, shares, totalShares

        // 0014: 59 MSIZE (stack: 0)
        // 0015: 35 CALLDATALOAD (stack: first calldata word)
        // 0016: 60E0 push 224 to stack for shr (stack: 0xE0, first calldata word)
        // 0018: 1C SHR (stack: selector)
        // 0019: 80808080 DUP1 selector 4x (stack: selector, selector, selector, selector, selector)
        // 001d: 63XXXXXXXX PUSH4 release selector (stack: release, selector, selector, selector, selector, selector)
        // 0022: 14 EQ (stack: isrelease, selector, selector, selector, selector)
        // 0023: 60XX push jump dest if release (stack: dest, isrelease, selector, selector, selector, selector)
        // 0025: 57 JUMPI dest condition (stack: selector, selector, selector, selector)
        // 0026: 63XXXXXXXX PUSH4 releaseToken selector (stack: releaseToken, selector, selector, selector, selector)
        // 002b: 14 EQ (stack: isreleaseToken, selector, selector, selector)
        // 002c: 60XX push jump dest if releaseToken (stack: dest, isreleaseToken, selector, selector, selector)
        // 002e: 57 JUMPI dest condition (stack: selector, selector, selector)
        // 002f: 63XXXXXXXX PUSH4 recipient selector (stack: recipient, selector, selector, selector)
        // 0034: 14 EQ (stack: isrecipient, selector, selector)
        // 0035: 60XX push jump dest if recipient (stack: dest, isrecipient, selector, selector)
        // 0037: 57 JUMPI dest condition (stack: selector, selector)
        // 0038: 63XXXXXXXX PUSH4 shares selector (stack: shares, selector, selector)
        // 003d: 14 EQ (stack: isshares, selector)
        // 003e: 60XX push jump dest if recipient (stack: dest, isshares, selector)
        // 0040: 57 JUMPI dest condition (stack: selector)
        // 0041: 63XXXXXXXX PUSH4 totalShares selector (stack: totalShares, selector)
        // 0046: 14 EQ (stack: istotalshares)
        // 0047: 60XX push jump dest if recipient (stack: dest, istotalshares)
        // 0049: 57 JUMPI dest condition (stack: empty)
        // 004a: 60006000F3 (fallback)


        // RELEASE FUNCTION

        // 5B476001
        // 004f: 5B JUMPDEST for release selector
        // 0050: 47 place contract balance on stack (stack: total disburse)
        // 0051: 6001 push 0x01 to stack to start success chain (stack: success, total disburse)

        // This section loops for each recipient (41 bytes) starting at 004b:
        // 5959595963XXXXXXXX8663XXXXXXXX020473XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX5AF116
        // ---- F1 (call) needs gas, addr, value, argsOffset, argsLength, retOffset, retLength on stack 
        // 59595959 (4x MSIZE) to push 4 zeroes to stack for arg/ret offset/length (stack: 0, 0, 0, 0, success, total disburse)
        // value will be 63XXXXXXXX to push total shares, 86 DUP7 to copy total disburse, 63XXXXXXXX to push recipient shares, 02 MUL, 04 DIV
        // -- (stack: total shares, 0, 0, 0, 0, success, total disburse)
        // -- (stack: total disburse, total shares, 0, 0, 0, 0, success, total disburse)
        // -- (stack: recipient shares, total disburse, total shares, 0, 0, 0, 0, success, total disburse)
        // -- (stack: recipient shares * total disburse, total shares, 0, 0, 0, 0, success, total disburse)
        // -- (stack: recipient shares * total disburse / total shares (payment), 0, 0, 0, 0, success, total disburse)
        // 73XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX recipient address
        // -- (stack: recipient, payment, 0, 0, 0, 0, success, total disburse)
        // 5A forward all gas remaining
        // -- (stack: gas remaining, recipient, payment, 0, 0, 0, 0, success, total disburse)
        // F1 CALL (stack: result, success, total disburse)
        // 16 AND to chain call successes for final check that all were sent (stack: success, total disburse)

        // 15600d57597FXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX5959A35959F3
        // 0053+(0x29*recipients): 15600d ISZERO on success, PUSH0 0x0d for generic failure (stack: 0x0d, failure, total disburse)
        // 0056+(0x29*recipients): 57 JUMPI if failure jump to generic revert (stack: total disburse)
        // 0057+(0x29*recipients): 59 MSIZE to get 0 for native token (stack: token, total disburse)
        // 0058+(0x29*recipients): 7FXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX PUSH32 SplitReleased event selector (stack: SplitReleased, token, total disburse)
        // 0079+(0x29*recipients): 5959 MSIZE MSIZE to push zeroes (stack: 0, 0, SplitReleased, token, total disburse)
        // 007b+(0x29*recipients): A3 LOG3 offset, length, topic0, topic1, topic2 (stack: empty)
        // 007c+(0x29*recipients): 5959F3 RETURN




        // RELEASE TOKEN FUNCTION

        // 5B600435602435
        // 007f+(0x29*recipients): 5B JUMPDEST for releaseToken selector
        // 0080+(0x29*recipients): 6004 PUSH1 0x04 to stack to load token address offset (stack: address offset)
        // 0082+(0x29*recipients): 35 CALLDATALOAD (stack: token address)
        // 0083+(0x29*recipients): 6024 PUSH1 0x24 to stack to load token deduct amount offset (stack: deduct amount offset, token address)
        // 0085+(0x29*recipients): 35 CALLDATALOAD (stack: deduct amount, token address)

        // 0086+(0x29*recipients): 6370a0823160E01B60005230600452602060006044600085FAFA15600d57600051818110600d5703
        // -- 6370a08231 PUSH4 balanceOf selector (stack: balanceOf selector, deduct amount, token address)
        // -- 60E0 PUSH1 224 for SHL (stack: 0xE0, balanceOf selector, deduct amount, token address)
        // -- 1B shift balanceOf selector left 28 bytes (stack: shifted balanceOf selector, deduct amount, token address)
        // -- 6000 PUSH1 0x00 memory offset (stack: 0x00, shifted balanceOf selector, deduct amount, token address)
        // -- 52 MSTORE balanceOf selector to memory[00:1f] left aligned (stack: deduct amount, token address)
        // -- 30 ADDRESS (stack: address(this), deduct amount, token address)
        // -- 6004 PUSH1 0x04 for address offset in memory (stack: 0x04, address(this), deduct amount, token address)
        // -- 52 MSTORE address to memory[04:23]
        // -- FA STATICCALL gas, addr, argsOffset, argsLength, retOffset, retLength
        // -- -- 6020600060446000 PUSH1 arg/ret offsets/lengths (stack: 0x00, 0x44, 0x00, 0x20, deduct amount, token address)
        // -- -- 85 DUP6 token address to top of stack (stack: token address, 0x00, 0x44, 0x00, 0x20, deduct amount, token address)
        // -- -- 5A forward all gas remaining (stack: gas remaining, token address, 0x00, 0x44, 0x00, 0x20, deduct amount, token address)
        // -- -- FA STATICCALL (stack: result, deduct amount, token address)
        // -- 15 ISZERO (stack: call failed, deduct amount, token address)
        // -- 600d PUSH0 0x0d for generic revert (stack: 0x0d, call failed, deduct amount, token address)
        // -- 57 JUMPI go to generic revert if call failed (stack: deduct amount, token address)
        // -- 6000 PUSH0 0x00 for result memory offset (stack: 0x00, deduct amount, token address)
        // -- 51 MLOAD (stack: balance, deduct amount, token address)
        // -- 8181 DUP2 balance and deduct amount for check (stack: balance, deduct amount, balance, deduct amount, token address)
        // -- 10 LT check if balance is less than deduct amount (stack: bal lt deduct, balance, deduct amount, token address)
        // -- 600d PUSH0 0x0d for generic revert (stack: 0x0d, bal lt deduct, balance, deduct amount, token address)
        // -- 57 JUMPI go to generic revert if balance lt deduct amount (stack: balance, deduct amount, token address)
        // -- 03 SUB get total disbursement (stack: total disburse, token address)


        // 00ae+(0x29*recipients): 63a9059cbb PUSH4 transfer selector (stack: transfer selector, total disburse, token address)
        // 00b3+(0x29*recipients): 60E0 PUSH1 224 for SHL (stack: 0xE0, transfer selector, total disburse, token address)
        // 00b5+(0x29*recipients): 1B shift transfer selector left 28 bytes (stack: shifted transfer selector, total disburse, token address)
        // 00b6+(0x29*recipients): 6000 PUSH1 0x00 memory offset (stack: 0x00, shifted transfer selector, total disburse, token address)
        // 00b8+(0x29*recipients): 52 MSTORE transfer selector to memory[00:1f] left aligned (stack: total disburse, token address)

        // 00b9+(0x29*recipients): 6001 PUSH1 0x01 to stack to start success chain (stack: success, total disburse, token address)

        // This section loops for each recipient (51 bytes) starting at 00bb+(0x29*recipients):
        // 60008060448163XXXXXXXX8663XXXXXXXX020473XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX60045260245280875AF116
        // ---- F1 (call) needs gas, addr, value, argsOffset, argsLength, retOffset, retLength on stack 
        // 600080604481 PUSH1 zero, DUP1, PUSH1 0x44, DUP2 to stack for arg/ret offset/length (stack: 0, 0x44, 0, 0, success, total disburse, token address)
        // value will be 63XXXXXXXX to push total shares, 86 DUP7 to copy total disburse, 63XXXXXXXX to push recipient shares, 02 MUL, 04 DIV
        // -- (stack: total shares, 0, 0x44, 0, 0, success, total disburse, token address)
        // -- (stack: total disburse, total shares, 0, 0x44, 0, 0, success, total disburse, token address)
        // -- (stack: recipient shares, total disburse, total shares, 0, 0x44, 0, 0, success, total disburse, token address)
        // -- (stack: recipient shares * total disburse, total shares, 0, 0x44, 0, 0, success, total disburse, token address)
        // -- (stack: recipient shares * total disburse / total shares (payment), 0, 0x44, 0, 0, success, total disburse, token address)
        // -- 73XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX recipient address (stack: recipient, payment, 0, 0x44, 0, 0, success, total disburse, token address)
        // -- 6004 PUSH1 memory offset for transfer to address (stack: 0x04, recipient, payment, 0, 0x44, 0, 0, success, total disburse, token address)
        // -- 52 MSTORE address to memory[04:23] (stack: payment, 0, 0x44, 0, 0, success, total disburse, token address)
        // -- 6024 PUSH1 memory offset for transfer to address (stack: 0x24, payment, 0, 0x44, 0, 0, success, total disburse, token address)
        // -- 52 MSTORE amount to memory[24:43] (stack: 0, 0x44, 0, 0, success, total disburse, token address)
        // -- 80 DUP1 for zero value (stack: 0, 0, 0x44, 0, 0, success, total disburse, token address)
        // -- 87 DUP8 to put token address on top of stack (stack: token address, 0, 0, 0x44, 0, 0, success, total disburse, token address)
        // -- 5A forward all gas remaining
        // -- -- (stack: gas remaining, token address, 0, 0, 0x44, 0, 0, success, total disburse, token address)
        // F1 CALL (stack: result, success, total disburse, token address)
        // 16 AND to chain call successes for final check that all were sent (stack: success, total disburse, token address)

        // 15600d57907FXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX600080A3600080F3
        // 00bb+(0x5c*recipients): 6000602452 PUSH1 0x24, PUSH1 0x00, MSTORE to clear memory (stack: 0x0d, failure, total disburse, token address)
        // 00c0+(0x5c*recipients): 15600d ISZERO on success, PUSH0 0x0d for generic failure (stack: 0x0d, failure, total disburse, token address)
        // 00c3+(0x5c*recipients): 57 JUMPI if failure jump to generic revert (stack: total disburse, token address)
        // 00c4+(0x5c*recipients): 90 SWAP1 to flip token/disbursement (stack: token, total disburse)
        // 00c5+(0x5c*recipients): 7FXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX PUSH32 SplitReleased event selector (stack: SplitReleased, token, total disburse)
        // 00e6+(0x5c*recipients): 600080 PUSH1 DUP1 to push zeroes (stack: 0, 0, SplitReleased, token, total disburse)
        // 00e7+(0x5c*recipients): A3 LOG3 offset, length, topic0, topic1, topic2 (stack: empty)
        // 00e8+(0x5c*recipients): 600080F3 RETURN


        // 00ec+(0x5c*recipients): 5B JUMPDEST for recipients selector

    }

    function release() external { }
    function releaseToken(address token, uint256 taxDeductAmount) external { }
    function recipients() external view returns (address[] memory) { }
    function shares() external view returns(uint256[] memory) { }
    function totalShares() external view returns(uint256) { }
}
