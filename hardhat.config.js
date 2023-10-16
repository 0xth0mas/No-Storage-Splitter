/* global ethers task */
require("@nomicfoundation/hardhat-toolbox");

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
    solidity: {
        version: "0.8.21",
        settings: {
            optimizer: {
                enabled: true,
                runs: 33_333,
            },
            evmVersion: "paris",
            viaIR: true
        },
    },
    gasReporter: {
        enabled: true,
        currency: "USD",
        gasPrice: 21,
        url: "http://localhost:8545",
    },
    networks: {
        hardhat: {
        }
    }
}
