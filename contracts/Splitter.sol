// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract Splitter {

    // 0x31966e21f1ea9a6ba07d0e49fe2fdca6cffa0bcce030b17899b22526a6a9bdad
    event SplitReleased(address token, uint256 totalAmount);

    constructor(address[] memory _recipients, uint256[] memory _shares) payable {
        assembly {
            let size := mload(_recipients)

            if or(or(iszero(size), gt(size, 0xff)), iszero(eq(size, mload(_shares)))) {
                revert(0, 0)
            }

            _recipients := add(_recipients, 0x20)
            _shares := add(_shares, 0x20)

            let offset
            let end := mul(0x20, size)
            let totalShares 
            for {} 1 {} {
                if iszero(lt(offset, end)) {
                    break
                }
                let tShares := mload(add(_shares, offset))
                if lt(add(totalShares, tShares), totalShares) {
                    revert(0, 0)
                }
                totalShares := add(totalShares, tShares)
                offset := add(offset, 0x20)
            }
            if gt(totalShares, 0xFFFFFFFF) {
                revert(0, 0)
            }

            let memOffset := mload(0x40)
            mstore(0x00, memOffset)

            mstore(memOffset, 0x5935156009576013565B5959F35B60006000FD5B593560E01C808080806386d1)
            mstore(add(memOffset, 0x20), or(or(or(or(shl(152, 0xa69f146053576353edd8f71461), shl(136, add(0x83, mul(0x29, size)))), shl(72, 0x57630e57d4ce1461)), shl(56, add(0xed, mul(0x5c, size)))), 0x576303314efa14))
            mstore(add(memOffset, 0x40), or(or(or(or(shl(248, 0x61), shl(232, add(0xfe, mul(0x75, size)))), shl(168, 0x57633a98ef391461)), shl(152, add(0x010f, mul(0x7e, size)))), shl(72, 0x5760006000F35B476001)))

            offset := 0
            memOffset := add(memOffset, 0x57)
            for {} 1 {} {
                if iszero(lt(offset, end)) {
                    break
                }
                let tShares := mload(add(_shares, offset))
                let tRecipient := mload(add(_recipients, offset))

                mstore(memOffset, or(or(or(or(shl(216, 0x5959595963), shl(184, totalShares)), shl(168, 0x8663)), shl(136, tShares)), shl(112, 0x020473)))
                mstore(add(memOffset, 0x12), or(shl(96, tRecipient), shl(72, 0x5AF116)))                  

                offset := add(offset, 0x20)
                memOffset := add(memOffset, 0x29)
            }

            mstore(memOffset, 0x15600d57597F31966e21f1ea9a6ba07d0e49fe2fdca6cffa0bcce030b17899b2)
            mstore(add(memOffset, 0x20), 0x2526a6a9bdad5959A35959F35B6004356024356370a0823160E01B6000523060)
            mstore(add(memOffset, 0x40), 0x04526020600060446000855AFA15600d57600051818110600d570363a9059cbb)
            mstore(add(memOffset, 0x60), shl(192, 0x60E01B6000526001))

            memOffset := add(memOffset, 0x68)

            offset := 0
            for {} 1 {} {
                if iszero(lt(offset, end)) {
                    break
                }
                let tShares := mload(add(_shares, offset))
                let tRecipient := mload(add(_recipients, offset))

                mstore(memOffset, or(or(or(or(shl(200, 0x60008060448163), shl(168, totalShares)), shl(152, 0x8663)), shl(120, tShares)), shl(96, 0x020473)))
                mstore(add(memOffset, 0x14), or(shl(96, tRecipient), shl(8, 0x60045260245280875AF116)))

                offset := add(offset, 0x20)
                memOffset := add(memOffset, 0x33)
            }

            mstore(memOffset, 0x15600d57907F31966e21f1ea9a6ba07d0e49fe2fdca6cffa0bcce030b17899b2)
            mstore(add(memOffset, 0x20), or(or(shl(88, 0x2526a6a9bdad600080A3600080F35B602060005260), shl(80, size)), shl(56, 0x602052)))

            memOffset := add(memOffset, 0x39)

            offset := 0
            for {} 1 {} {
                if iszero(lt(offset, end)) {
                    break
                }
                let tRecipient := mload(add(_recipients, offset))

                mstore(memOffset, or(or(or(or(shl(248, 0x73), shr(8, shl(96, tRecipient))), shl(80, 0x61)), shl(64, add(offset, 0x40))), shl(56, 0x52)))

                offset := add(offset, 0x20)
                memOffset := add(memOffset, 0x19)
            }

            mstore(memOffset, or(or(or(or(shl(248, 0x61), shl(232, add(0x40, mul(size, 0x20)))), shl(152, 0x6000F35B602060005260)), shl(144, size)), shl(120, 0x602052)))

            memOffset := add(memOffset, 0x11)
            
            offset := 0
            for {} 1 {} {
                if iszero(lt(offset, end)) {
                    break
                }
                let tShares := mload(add(_shares, offset))

                mstore(memOffset, or(or(or(or(shl(248, 0x63), shl(216, tShares)), shl(208, 0x61)), shl(192, add(offset, 0x40))), shl(184, 0x52)))

                offset := add(offset, 0x20)
                memOffset := add(memOffset, 0x09)
            }

            mstore(memOffset, or(or(or(or(shl(248, 0x61), shl(232, add(0x40, mul(size, 0x20)))), shl(192, 0x6000F35B63)), shl(160, totalShares)), shl(96, 0x60005260206000F3)))
            memOffset := add(memOffset, 0x14)

            return(mload(0x00), sub(memOffset, mload(0x00)))

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

        // 593560E01C808080806386d1a69f146053576353edd8f71461XXXX57630e57d4ce1461XXXX576303314efa1461XXXX57633a98ef391461XXXX5760006000F3
        // 0014: 59 MSIZE (stack: 0)
        // 0015: 35 CALLDATALOAD (stack: first calldata word)
        // 0016: 60E0 push 224 to stack for shr (stack: 0xE0, first calldata word)
        // 0018: 1C SHR (stack: selector)
        // 0019: 80808080 DUP1 selector 4x (stack: selector, selector, selector, selector, selector)
        // 001d: 6386d1a69f PUSH4 release selector (stack: release, selector, selector, selector, selector, selector)
        // 0022: 14 EQ (stack: isrelease, selector, selector, selector, selector)
        // 0023: 6053 push jump dest if release (stack: dest, isrelease, selector, selector, selector, selector)
        // 0025: 57 JUMPI dest condition (stack: selector, selector, selector, selector)
        // 0026: 6353edd8f7 PUSH4 releaseToken selector (stack: releaseToken, selector, selector, selector, selector)
        // 002b: 14 EQ (stack: isreleaseToken, selector, selector, selector)
        // 002c: 61XXXX push jump dest if releaseToken (stack: dest, isreleaseToken, selector, selector, selector)
        // 002f: 57 JUMPI dest condition (stack: selector, selector, selector)
        // 0030: 630e57d4ce PUSH4 recipient selector (stack: recipient, selector, selector, selector)
        // 0035: 14 EQ (stack: isrecipient, selector, selector)
        // 0036: 61XXXX push jump dest if recipient (stack: dest, isrecipient, selector, selector)
        // 0039: 57 JUMPI dest condition (stack: selector, selector)
        // 003a: 6303314efa PUSH4 shares selector (stack: shares, selector, selector)
        // 003f: 14 EQ (stack: isshares, selector)
        // 0040: 61XXXX push jump dest if recipient (stack: dest, isshares, selector)
        // 0043: 57 JUMPI dest condition (stack: selector)
        // 0044: 633a98ef39 PUSH4 totalShares selector (stack: totalShares, selector)
        // 0049: 14 EQ (stack: istotalshares)
        // 004a: 61XXXX push jump dest if recipient (stack: dest, istotalshares)
        // 004d: 57 JUMPI dest condition (stack: empty)
        // 004e: 60006000F3 (fallback)


        // RELEASE FUNCTION

        // 5B476001
        // 0053: 5B JUMPDEST for release selector
        // 0054: 47 place contract balance on stack (stack: total disburse)
        // 0055: 6001 push 0x01 to stack to start success chain (stack: success, total disburse)

        // This section loops for each recipient (41 bytes) starting at 0057:
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

        // 15600d57597F31966e21f1ea9a6ba07d0e49fe2fdca6cffa0bcce030b17899b22526a6a9bdad5959A35959F3
        // 0057+(0x29*recipients): 15600d ISZERO on success, PUSH0 0x0d for generic failure (stack: 0x0d, failure, total disburse)
        // 005a+(0x29*recipients): 57 JUMPI if failure jump to generic revert (stack: total disburse)
        // 005b+(0x29*recipients): 59 MSIZE to get 0 for native token (stack: token, total disburse)
        // 005c+(0x29*recipients): 7F31966e21f1ea9a6ba07d0e49fe2fdca6cffa0bcce030b17899b22526a6a9bdad PUSH32 SplitReleased event selector (stack: SplitReleased, token, total disburse)
        // 007d+(0x29*recipients): 5959 MSIZE MSIZE to push zeroes (stack: 0, 0, SplitReleased, token, total disburse)
        // 007f+(0x29*recipients): A3 LOG3 offset, length, topic0, topic1, topic2 (stack: empty)
        // 0080+(0x29*recipients): 5959F3 RETURN




        // RELEASE TOKEN FUNCTION

        // 5B600435602435
        // 0083+(0x29*recipients): 5B JUMPDEST for releaseToken selector
        // 0084+(0x29*recipients): 6004 PUSH1 0x04 to stack to load token address offset (stack: address offset)
        // 0086+(0x29*recipients): 35 CALLDATALOAD (stack: token address)
        // 0087+(0x29*recipients): 6024 PUSH1 0x24 to stack to load token deduct amount offset (stack: deduct amount offset, token address)
        // 0089+(0x29*recipients): 35 CALLDATALOAD (stack: deduct amount, token address)

        // 008a+(0x29*recipients): 6370a0823160E01B600052306004526020600060446000855AFA15600d57600051818110600d5703
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


        // 63a9059cbb60E01B6000526001
        // 00b2+(0x29*recipients): 63a9059cbb PUSH4 transfer selector (stack: transfer selector, total disburse, token address)
        // 00b7+(0x29*recipients): 60E0 PUSH1 224 for SHL (stack: 0xE0, transfer selector, total disburse, token address)
        // 00b9+(0x29*recipients): 1B shift transfer selector left 28 bytes (stack: shifted transfer selector, total disburse, token address)
        // 00ba+(0x29*recipients): 6000 PUSH1 0x00 memory offset (stack: 0x00, shifted transfer selector, total disburse, token address)
        // 00bc+(0x29*recipients): 52 MSTORE transfer selector to memory[00:1f] left aligned (stack: total disburse, token address)
        // 00bd+(0x29*recipients): 6001 PUSH1 0x01 to stack to start success chain (stack: success, total disburse, token address)

        // This section loops for each recipient (51 bytes) starting at 00bf+(0x29*recipients):
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

        // 15600d57907F31966e21f1ea9a6ba07d0e49fe2fdca6cffa0bcce030b17899b22526a6a9bdad600080A3600080F3
        // 00bf+(0x5c*recipients): 6000602452 PUSH1 0x24, PUSH1 0x00, MSTORE to clear memory (stack: 0x0d, failure, total disburse, token address)
        // 00c4+(0x5c*recipients): 15600d ISZERO on success, PUSH0 0x0d for generic failure (stack: 0x0d, failure, total disburse, token address)
        // 00c7+(0x5c*recipients): 57 JUMPI if failure jump to generic revert (stack: total disburse, token address)
        // 00c8+(0x5c*recipients): 90 SWAP1 to flip token/disbursement (stack: token, total disburse)
        // 00c9+(0x5c*recipients): 7F31966e21f1ea9a6ba07d0e49fe2fdca6cffa0bcce030b17899b22526a6a9bdad PUSH32 SplitReleased event selector (stack: SplitReleased, token, total disburse)
        // 00ea+(0x5c*recipients): 600080 PUSH1 DUP1 to push zeroes (stack: 0, 0, SplitReleased, token, total disburse)
        // 00ed+(0x5c*recipients): A3 LOG3 offset, length, topic0, topic1, topic2 (stack: empty)
        // 00ee+(0x5c*recipients): 600080F3 RETURN


        // RECIPIENTS FUNCTION

        // 5B602060005260XX602052
        // 00f2+(0x5c*recipients): 5B JUMPDEST for recipients selector
        // 00f3+(0x5c*recipients): 6020600052 PUSH1 0x20, PUSH1 0x00, MSTORE to set return array (stack: empty)
        // 00f8+(0x5c*recipients): 60XX602052 PUSH recipients length, memory storage position, MSTORE (stack: empty)

        // This section loops for each recipient (25 bytes) starting at 00fd+(0x5c*recipients):
        // 73XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX61XXXX52
        // -- 73XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX PUSH recipient address (stack: recipient)
        // -- 61XXXX PUSH memory storage location (0x40 + 0x20 * recipient index) (stack: memory offset, recipient)
        // -- 52 MSTORE recipient to memory (stack: empty)

        // 00fd+(0x75*recipients): 61XXXX PUSH2 return length (recipients * 0x20 + 0x40) (stack: memory length)
        // 0100+(0x75*recipients): 6000 start return position (0, memory length)
        // 0102+(0x75*recipients): F3 RETURN


        // SHARES FUNCTION

        // 5B602060005260XX602052
        // 0103+(0x75*recipients): 5B JUMPDEST for shares selector
        // 0104+(0x75*recipients): 6020600052 PUSH1 0x20, PUSH1 0x00, MSTORE to set return array (stack: empty)
        // 0109+(0x75*recipients): 60XX602052 PUSH shares length, memory storage position, MSTORE (stack: empty)

        // This section loops for each recipient shares (9 bytes) starting at 010e+(0x75*recipients):
        // 63XXXXXXXX61XXXX52
        // -- 63XXXXXXXX PUSH recipient share (stack: share)
        // -- 61XXXX PUSH memory storage location (0x40 + 0x20 * recipient share index) (stack: memory offset, share)
        // -- 52 MSTORE share to memory (stack: empty)

        // 010e+(0x7e*recipients): 61XXXX PUSH2 return length (recipient shares * 0x20 + 0x40) (stack: memory length)
        // 0111+(0x7e*recipients): 6000 start return position (0, memory length)
        // 0113+(0x7e*recipients): F3 RETURN


        // TOTAL SHARES FUNCTION

        // 5B63XXXXXXXX60005260206000F3
        // 0114+(0x7e*recipients): 5B JUMPDEST for total shares selector
        // 0115+(0x7e*recipients): 63XXXXXXXX PUSH4 total shares (stack: total shares)
        // 011a+(0x7e*recipients): 6000 PUSH1 memory offset (stack: 0, total shares)
        // 011c+(0x7e*recipients): 52 MSTORE total shares to memory (stack: empty)

        // 011d+(0x7E*recipients): 6020 PUSH1 return length 0x20 (stack: 0x20)
        // 011f+(0x7E*recipients): 6000 start return position (0, 0x20)
        // 0121+(0x7E*recipients): F3 RETURN

    }

    function release() external { }
    function releaseToken(address token, uint256 taxDeductAmount) external { }
    function recipients() external view returns (address[] memory) { }
    function shares() external view returns(uint256[] memory) { }
    function totalShares() external view returns(uint256) { }
}
