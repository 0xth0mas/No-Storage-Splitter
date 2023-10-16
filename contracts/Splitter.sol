// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract Splitter {

    event SplitReleased(address token, address[] recipients, uint256[] amounts);

    constructor(address[] memory _recipients, uint256[] memory _shares) payable {
        bytes4 releaseSelector = Splitter.release.selector;
        bytes4 releaseTokenSelector = Splitter.releaseToken.selector;
        bytes4 recipientsSelector = Splitter.recipients.selector;
        bytes4 sharesSelector = Splitter.shares.selector;
        bytes4 totalShares = Splitter.totalShares.selector;
        assembly {
            let size := mload(_recipients)

            if iszero(size) {
                revert(0, 0)
            }
            if iszero(eq(size, mload(_shares))) {
                revert(0, 0)
            }
        }

        // 593515600957600D565B5959F35B
        // 0000: 59 MSIZE (stack: 0)
        // 0001: 35 CALLDATALOAD (stack: first calldata word)
        // 0002: 15 ISZERO (stack: calldataiszero)
        // 0003: 6009 push jump dest if calldata is zero (receive/fallback) (stack: 9, calldataiszero)
        // 0005: 57 JUMPI dest condition (stack: empty)
        // 0006: 600D push jump dest PC if calldata is nonzero (stack: 0x0D)
        // 0008: 56 JUMP (stack: empty)
        // 0009: 5B JUMPDEST (stack: empty)
        // 000a: 5959 MSIZE MSIZE (stack: 0, 0)
        // 000c: F3 RETURN
        // 000d: 5B JUMPDEST (stack: empty)

        // FUNCTION SELECTOR - release, releaseToken, recipients, shares, totalShares

        // 000e: 59 MSIZE (stack: 0)
        // 000f: 35 CALLDATALOAD (stack: first calldata word)
        // 0010: 60E0 push 224 to stack for shr (stack: 0xE0, first calldata word)
        // 0011: 1C SHR (stack: selector)
        // 0012: 80808080 DUP1 selector 4x (stack: selector, selector, selector, selector, selector)
        // 0016: 63XXXXXXXX PUSH4 release selector (stack: release, selector, selector, selector, selector, selector)
        // 001b: 14 EQ (stack: isrelease, selector, selector, selector, selector)
        // 001c: 60XX push jump dest if release (stack: dest, isrelease, selector, selector, selector, selector)
        // 001e: 57 JUMPI dest condition (stack: selector, selector, selector, selector)
        // 001f: 63XXXXXXXX PUSH4 releaseToken selector (stack: releaseToken, selector, selector, selector, selector)
        // 0024: 14 EQ (stack: isreleaseToken, selector, selector, selector)
        // 0025: 60XX push jump dest if releaseToken (stack: dest, isreleaseToken, selector, selector, selector)
        // 0027: 57 JUMPI dest condition (stack: selector, selector, selector)
        // 0028: 63XXXXXXXX PUSH4 recipient selector (stack: recipient, selector, selector, selector)
        // 002d: 14 EQ (stack: isrecipient, selector, selector)
        // 002e: 60XX push jump dest if recipient (stack: dest, isrecipient, selector, selector)
        // 0030: 57 JUMPI dest condition (stack: selector, selector)
        // 0031: 63XXXXXXXX PUSH4 shares selector (stack: shares, selector, selector)
        // 0036: 14 EQ (stack: isshares, selector)
        // 0037: 60XX push jump dest if recipient (stack: dest, isshares, selector)
        // 0039: 57 JUMPI dest condition (stack: selector)
        // 003a: 63XXXXXXXX PUSH4 totalShares selector (stack: totalShares, selector)
        // 003f: 14 EQ (stack: istotalshares)
        // 0040: 60XX push jump dest if recipient (stack: dest, istotalshares)
        // 0042: 57 JUMPI dest condition (stack: empty)
        // 0043: 60006000F3 (fallback)


        // 0048: 5B JUMPDEST for release selector

        // 476001
        // 47 place contract balance on stack (stack: total disburse)
        // 6001 push 0x01 to stack to start success chain (stack: success, total disburse)

        // This section loops for each recipient:
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

    }

    function release() external { }
    function releaseToken(address token) external { }
    function recipients() external view returns (address[] memory) { }
    function shares() external view returns(uint256[] memory) { }
    function totalShares() external view returns(uint256) { }
}
