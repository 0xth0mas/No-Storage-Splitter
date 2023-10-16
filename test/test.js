const {
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("Test", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deploySplitter() {
    

    // Contracts are deployed using the first signer/account by default
    const [owner, account1, account2] = await ethers.getSigners();

    const SplitterFactory = await ethers.getContractFactory("Splitter");
    const splitter = await SplitterFactory.deploy([account1.address, account2.address], [1000, 2000]);

    

    const sendEth1 = { to: splitter.target, value: ethers.parseEther("0.1") }
    const receiptTx1 = await owner.sendTransaction(sendEth1);
    await receiptTx1.wait();

    return { splitter, owner, account1, account2 };
  }

  describe("Test", function () {
    it("Should work", async function () {
      const { splitter, owner, account1, account2 } = await loadFixture(deploySplitter);

      console.log("Owner balance: " + await ethers.provider.getBalance(splitter.target));
      console.log("Payment #1 balance: " + await ethers.provider.getBalance(account1.address));
      console.log("Payment #2 balance: " + await ethers.provider.getBalance(account2.address));
      console.log(await splitter.release())
      console.log("Owner balance: " + await ethers.provider.getBalance(splitter.target));
      console.log("Payment #1 balance: " + await ethers.provider.getBalance(account1.address));
      console.log("Payment #2 balance: " + await ethers.provider.getBalance(account2.address));
    });
  });
});
